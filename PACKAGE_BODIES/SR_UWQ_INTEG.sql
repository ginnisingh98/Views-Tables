--------------------------------------------------------
--  DDL for Package Body SR_UWQ_INTEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SR_UWQ_INTEG" AS
/* $Header: cssruwqb.pls 120.3.12010000.2 2010/05/11 10:24:03 vpremach ship $ */

------------------------------------------------------------------------------
--  Parameters	:
--	p_ieu_media_data	IN	SYSTEM.IEW_UWQ_MEDIA_DATA_NST	Required
--   p_action_type		OUT  NUMBER
--   p_action_name		OUT  VARCHAR2
--   p_action_param		OUT  VARCHAR2
--
------------------------------------------------------------------------------

procedure sr_uwq_foo_func
  ( p_ieu_media_data IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
    p_action_type   OUT NOCOPY NUMBER,
    p_action_name   OUT NOCOPY VARCHAR2,
    p_action_param  OUT NOCOPY VARCHAR2) IS

  n_ctn   number;
  l_name  varchar2(500);
  l_value varchar2(1996);
  l_type  varchar2(500);
  l_incident_id number;

  l_sr_uwq_call varchar2(50);
  l_sr_uwq_parameter varchar2(50);
  l_sr_uwq_param_value varchar2(50);
  l_sr_uwq_param_id number;
  l_sr_uwq_param_message varchar2(150);
  l_sr_uwq_action varchar2(50);
  l_sr_uwq_action_value varchar2(30);
  l_sr_uwq_exp_action   varchar2(30);
  l_sr_uwq_call_type varchar2(50);
  l_topmost_tab_page varchar2(50);

-- These parameters will default the customer info on
-- the Call to Issue scenario.
  l_customer_id   number;
  l_customer      varchar2(360);
  l_customer_type varchar2(30);

-- The variables below are for call transfer
  n_party_id        number;
  n_cust_party_id   number;
  n_rel_party_id    number;
  n_per_party_id    number;
  n_cust_phone_id   number;
  n_rel_phone_id    number;
  n_cust_account_id number;
  n_interaction_id  number;
  n_action_id       number;
  n_uwq_ani         number;
  v_service_key_name  varchar2(40);
  v_service_key_value varchar2(2000);
  v_call_reason       varchar2(40);


  x_return_status varchar2(10);
  x_parameter_flag varchar2(20);
  v_parameter_char varchar2(80);

  BEGIN

--      p_action_param       := 'SR_UWQ_CALL="YES"';
-- The below code intializes the parameters that will be passed to
-- the Service Request form. These will be decoded and used to control
-- the flow of the form.

      n_ctn                  := 1;
      l_sr_uwq_call          := 'SR_UWQ_CALL="YES"';
      l_sr_uwq_parameter     := 'NO_DATA';
      l_sr_uwq_param_value   := 'NO_DATA';
      l_sr_uwq_param_message := 'NO_DATA';
      l_sr_uwq_action        := 'NO_DATA';
      l_sr_uwq_action_value  := 'QUERY_SR';
      l_sr_uwq_exp_action    := 'NO_DATA';
      l_sr_uwq_call_type     := 'SR_UWQ_CALL_TYPE="SR_REGULAR"';
      l_topmost_tab_page     := 'NO_DATA';

      n_action_id := 0;

  for i IN 1..p_ieu_media_data.COUNT
  loop
    l_name  := p_ieu_media_data(i).param_name;
    l_value := p_ieu_media_data(i).param_value;
    l_type  := p_ieu_media_data(i).param_type;

    --  Process the IVR table entries
/*
insert into uwq_temp values(l_name, l_value, l_type,n_ctn,sysdate);
commit;
n_ctn := n_ctn + 1;
*/
    IF l_name = 'occtEventName' THEN
--        p_action_param := p_action_param||'uwq_event="'||l_value||'"';
null;
-- Simba

    ELSIF l_name = 'occtAgentID' THEN
        p_action_param := p_action_param||'uwq_agent="'||l_value||'"';

    ELSIF l_name = 'occtANI' THEN
        p_action_param := p_action_param||'uwq_ani="'||l_value||'"';
        n_uwq_ani := l_value;

    ELSIF l_name = 'occtDNIS' THEN
        p_action_param := p_action_param||'uwq_dnis="'||l_value||'"';

    ELSIF l_name = 'occtMediaItemID' THEN
        p_action_param := p_action_param||'uwq_media_item_id="'||l_value||'"';

    ELSIF l_name = 'workItemID' THEN
        p_action_param := p_action_param||'uwq_work_item_id="'||l_value||'"';

    ELSIF l_name = 'occtMediaType' THEN
        p_action_param := p_action_param||'uwq_media_type="'||l_value||'"';

    ELSIF l_name = 'occtCallID' THEN
        p_action_param := p_action_param||'uwq_call_id="'||l_value||'"';

    ELSIF l_name = 'occtScreenPopAction' THEN
        if l_value = 'CreateSR' then
           l_value := 'CREATE_SR';
        elsif l_value = 'InquireSR' then
           l_value := 'QUERY_SR';
        else
           l_value := 'QUERY_SR';
        end if;
        l_sr_uwq_action        := 'SR_UWQ_ACTION="'||l_value||'"';
        l_sr_uwq_action_value  := l_value;

    ELSIF l_name = 'ServiceRequestNum' THEN
        l_sr_uwq_parameter := 'SR_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'AccountCode' THEN
        l_sr_uwq_parameter := 'SR_ACC_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'SerialNum' THEN
        l_sr_uwq_parameter := 'SR_SERIAL_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'TagNumber' THEN
        l_sr_uwq_parameter := 'SR_TAG_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'CustomerNum' THEN
        l_sr_uwq_parameter := 'SR_PARTY_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'PhoneNumber' THEN
        l_sr_uwq_parameter := 'SR_PHONE_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'RMANum' THEN
        l_sr_uwq_parameter := 'SR_RMA_NUMBER';
        l_sr_uwq_param_value := l_value;

    ELSIF l_name = 'ContractNum' THEN
        l_sr_uwq_parameter := 'SR_CONTRACT_NUMBER';
        l_sr_uwq_param_value := l_value;

-- The code below are used for transfer between applications

    ELSIF l_name = 'CUST_PARTY_ID' THEN
        n_cust_party_id := l_value;

    ELSIF l_name = 'REL_PARTY_ID' THEN
        n_rel_party_id := l_value;

    ELSIF l_name = 'PER_PARTY_ID' THEN
        n_per_party_id := l_value;

    ELSIF l_name = 'CUST_PHONE_ID' THEN
        n_cust_phone_id := l_value;

    ELSIF l_name = 'REL_PHONE_ID' THEN
        n_rel_phone_id := l_value;

    ELSIF l_name = 'CUST_ACCOUNT_ID' THEN
        n_cust_account_id := l_value;

    ELSIF l_name = 'INTERACTION_ID' THEN
        n_interaction_id := l_value;

    ELSIF l_name = 'ACTION_ID' THEN
        n_action_id := l_value;

    ELSIF l_name = 'SERVICE_KEY_NAME' THEN
        v_service_key_name := l_value;

    ELSIF l_name = 'SERVICE_KEY_VALUE' THEN
        v_service_key_value := l_value;

    ELSIF l_name = 'CALL_REASON' THEN
        v_call_reason := l_value;

    end if;

  end loop;              -- End of loop of searching through parameters.

-- The code below handles the transfer and Conf. of calls.
-- 63 is Transfer and 64 is Conference.

  if n_action_id in (63,64) then

     if nvl(n_cust_party_id,0) <> 0 then
        n_party_id := n_cust_party_id;
     elsif nvl(n_per_party_id,0) <> 0 then
        n_party_id := n_per_party_id;
     else
        n_party_id := -1;
     end if;

     sr_uwq_integ.interpret_service_keys(v_service_key_name,
                                         v_service_key_value,
                                         n_party_id,
                                         n_cust_account_id,
                                         n_cust_phone_id,
                                         l_sr_uwq_parameter,
                                         x_return_status);

     l_sr_uwq_param_value  := v_service_key_value;
     l_sr_uwq_action_value := 'QUERY_SR';
     l_sr_uwq_action       := 'SR_UWQ_ACTION="'||l_sr_uwq_action_value||'"';

     if n_action_id = 63 then
        l_sr_uwq_call_type    := 'SR_UWQ_CALL_TYPE="SR_TRANSFER"';
     elsif n_action_id = 64 then
        l_sr_uwq_call_type    := 'SR_UWQ_CALL_TYPE="SR_CONF"';
     end if;

  end if;  /* End of if for n_action_id = 63,64 */

     /* This is a case where the incoming call is from the UWQ and
        the call did not have any other parameter and we have to use the
        ANI to get more data.  */

  if l_sr_uwq_parameter = 'NO_DATA' then
     l_sr_uwq_parameter := 'SR_ANI';
     l_sr_uwq_param_value := n_uwq_ani;

  elsif l_sr_uwq_parameter is not null
             and ltrim(rtrim(l_sr_uwq_param_value)) is null  then
     l_sr_uwq_parameter := 'SR_ANI';
     l_sr_uwq_param_value := n_uwq_ani;

  end if;

-- The parameter SR_UWQ_CALL is set to YES here.
  p_action_param := p_action_param||l_sr_uwq_call;

  sr_uwq_integ.validate_ivr_parameter(
                  l_sr_uwq_parameter,
                  l_sr_uwq_param_value,
                  l_sr_uwq_param_message,
                  l_sr_uwq_action_value,
                  l_sr_uwq_param_id,
                  x_parameter_flag,
                  l_customer_id,
                  l_customer_type,
                  x_return_status);

  if l_sr_uwq_parameter = 'SR_NUMBER' and l_sr_uwq_param_id <> -1  then
     p_action_param := p_action_param||'REQUEST_NUMBER="'||l_sr_uwq_param_value||'"';
     p_action_param := p_action_param||'SR_UWQ_PARAM_VALUE="'||l_sr_uwq_param_value||'"';
  else
     p_action_param := p_action_param||'SR_UWQ_PARAM_VALUE="'||l_sr_uwq_param_value||'"';
  end if;

  p_action_type := 1;  -- This means app_navigate

-- This section of the code decides on what form to call. Depending on the
-- Action type different forms are popped up. SR_UWQ_ACTION
-- Call To Issue ----> CSXSRISR,  Call to Inquiry ---> CSXSRISR, and CSXSRISV.

  if nvl(l_sr_uwq_action_value,'QUERY_SR') = 'QUERY_SR' then
      if l_sr_uwq_parameter = 'SR_NUMBER' and l_sr_uwq_param_id <> -1 then
         p_action_name := 'CSXSRISR';
      else
         p_action_name := 'CSXSRISV';
      end if;

   elsif l_sr_uwq_action_value = 'CREATE_SR' then
      p_action_name := 'CSXSRISR';

   else
      p_action_name := 'CSXSRISR';
   end if;

-- The parameter SR_UWQ_ACTION is set here. This will be used by the
-- Lib CSSRUWQ.pll to navigate and default values.

   if l_sr_uwq_action = 'NO_DATA' then
      l_sr_uwq_action   := 'SR_UWQ_ACTION="'||l_sr_uwq_action_value||'"';
   end if;
   p_action_param    := p_action_param||l_sr_uwq_action;


-- This section of the code appends the IVR Value and the ID of the value
-- to the parameter list for the form to process. Output of the function to validate
-- the IVR parameter.

   if x_return_status = 'S' then
        p_action_param := p_action_param||'SR_UWQ_PARAMETER="'||l_sr_uwq_parameter||'"';
        p_action_param := p_action_param||'SR_UWQ_PARAM_ID="'||l_sr_uwq_param_id||'"';
   end if;

-- This section of code adds the Customer related info to the parameter
-- string. This would happen only when the customer info is retriveable for
-- the passed IVR parameter.
   if x_parameter_flag = 'VALID_CUSTOMER' then
      if l_customer_id is not null then
         p_action_param := p_action_param||'SR_UWQ_CUST_ID="'||l_customer_id||'"';
      end if;

      if l_customer_type is not null then
         p_action_param := p_action_param||'SR_UWQ_CUST_TYPE="'||l_customer_type||'"';
      end if;
   else
         p_action_param := p_action_param||'SR_UWQ_CUST_ID="-1"';

   end if;

-- The parameter SR_UWQ_CALL_TYPE is set here. This will be used to identify if
-- it is a Transfer, or Conference, or Regular Queue call
-- For outbound calls it is set to SR_OUTBOUND
   p_action_param := p_action_param||l_sr_uwq_call_type;

-- The parameter SR_UWQ_PARAM_MESSAGE is set here. This will be used to pass any extra
-- info from the foo function to the form.
   if l_sr_uwq_param_message <> 'NO_DATA' then
      p_action_param := p_action_param||'SR_UWQ_PARAM_MESSAGE="'||l_sr_uwq_param_message||'"';
   end if;

-- This parameter will make override the Cancel, Save, Discard message and force the
-- the SR UWQ Alert pop up window to come up. This is used in the Restart scenario.
      p_action_param := p_action_param||'FIRE_CLEAR_FORM="N"';

end sr_uwq_foo_func;

procedure connect_form_to_foo
 ( p_ieu_media_data in IEU_FRM_PVT.t_ieu_media_data,
  p_action_type     out NOCOPY number,
  p_action_name     out NOCOPY varchar2,
  p_action_param    out NOCOPY varchar2) is

  api_ivr_param_list system.IEU_UWQ_MEDIA_DATA_NST;

begin

  api_ivr_param_list := system.IEU_UWQ_MEDIA_DATA_NST();

  for i IN p_ieu_media_data.first..p_ieu_media_data.last
  loop
    api_ivr_param_list.extend;
    api_ivr_param_list(api_ivr_param_list.LAST) := SYSTEM.IEU_UWQ_MEDIA_DATA_OBJ(p_ieu_media_data(i).param_name,
                                                        p_ieu_media_data(i).param_value,
                                                        p_ieu_media_data(i).param_type);

  end loop;

  sr_uwq_integ.sr_uwq_foo_func(api_ivr_param_list,
            p_action_type, p_action_name, p_action_param);

end connect_form_to_foo;

/*======================================================================+
  ==
  ==  Procedure name      :enumerate_sr_nodes
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  07-dec-2004  VARNARAY   Made changes for Bug 3818940.
  ==  29-SEP-2005  PRAYADUR   Fix for Bug 4434093 added.
  ========================================================================*/
procedure enumerate_sr_nodes
  (p_resource_id      in number,
   p_language         in varchar2,
   p_source_lang      in varchar2,
   p_sel_enum_id      in number)  as

  l_node_label 		varchar2(100);
  l_sr_list 		IEU_PUB.EnumeratorDataRecordList;
  l_bind_list           IEU_PUB.BindVariableRecordList;
  l_node_counter	number;

  l_team_id    	   	number;
  l_team_name		varchar2(30);
  l_group_id    	number;
  l_group_name		varchar2(60);
  l_where_clause	varchar2(500);
  l_parent_where_clause	varchar2(500);
  l_sr_name		varchar2(30);
  return_value		varchar2(2000);

  l_view_name		varchar2(50);
  l_data_source		varchar2(50);
  n_where_clause	varchar2(500);
  l_cursor_sql		varchar2(1500);
  l_node_id 		number;
  l_id_of_value		number;
  l_parent_id 		number;
  l_where_value		varchar2(500);
  l_cursor_key_col	varchar2(30);
  l_value_flag		varchar2(10);
  l_node_query		varchar2(10);

  cursor team_cursor is select distinct team_mem.team_id,team_tl.team_name
  from jtf_rs_team_members team_mem, jtf_rs_teams_tl team_tl
  where team_resource_id = p_resource_id
  and team_mem.team_id = team_tl.team_id
  and team_tl.language = userenv('LANG');

  cursor group_cursor is select distinct group_mem.group_id,group_tl.group_name
  from jtf_rs_group_members group_mem, jtf_rs_groups_tl group_tl
  where group_mem.resource_id = p_resource_id
  and group_mem.group_id = group_tl.group_id
  and group_tl.language = userenv('LANG');

  l_lookup_code		varchar2(30);
  l_meaning		varchar2(360);--5579863
  l_level 		number;
  l_res_cat_enum_flag	varchar2(1);

  cursor all_cursor is select node_label,node_view,cursor_key_col,cursor_sql,
  data_source
  from cs_sr_uwq_nodes_b uwq_b, cs_sr_uwq_nodes_tl uwq_tl
  where uwq_b.node_id = uwq_tl.node_id
  and   uwq_tl.language = userenv('LANG')
  and parent_id = l_node_id
  and node_query='CURSOR' and enabled_flag='Y';

  cursor node_cursor is select 'Node ',
  node_view,where_clause,data_source,level,node_query,cursor_sql,
  uwq_b.node_id,res_cat_enum_flag
  from cs_sr_uwq_nodes_b uwq_b
  where node_id > 9999 and node_query='SINGLE' and enabled_flag='Y'
  and ( parent_id is null or parent_id > 9999 )
  start with uwq_b.parent_id is null
  connect by prior uwq_b.node_id = uwq_b.parent_id;

  cursor seed_cursor is select 'Node',
  node_view,where_clause,data_source,node_query,cursor_sql,
  uwq_b.node_id,res_cat_enum_flag,level,nvl(parent_id,-1)
  from cs_sr_uwq_nodes_b uwq_b
  where enabled_flag='Y'
  --where node_id < 1000 and enabled_flag='Y'
  and node_query = 'SINGLE'
  start with uwq_b.parent_id is null
  connect by prior uwq_b.node_id = uwq_b.parent_id;

  cursor cur_seed_cursor is select node_label,
  node_view,where_clause,data_source,node_query,cursor_sql,
  cursor_key_col,node_id,res_cat_enum_flag
  from cs_sr_uwq_nodes_vl
  where node_id < 1000 and enabled_flag='Y'
  and node_query = 'CURSOR';

   v_cursorid	number;
   v_dummy	number;

begin

  begin
     select name into l_sr_name from jtf_objects_vl
     where object_code='SR';
  exception
     when OTHERS then
        l_sr_name := 'SR Error';
  end;

  l_node_counter := 0;
  savepoint start_cs_enum;

  l_sr_list(l_node_counter).node_label := l_sr_name;
  l_sr_list(l_node_counter).view_name := 'CS_SR_UWQ_LABEL_V';
  l_sr_list(l_node_counter).data_source := 'CS_SR_UWQ_LABEL_DS';
  l_sr_list(l_node_counter).media_type_id := '';
  l_sr_list(l_node_counter).where_clause := ' incident_id = -1 ';
  l_sr_list(l_node_counter).node_type := 0;
  l_sr_list(l_node_counter).hide_if_empty := '';
  l_sr_list(l_node_counter).res_cat_enum_flag := 'N';
  l_sr_list(l_node_counter).node_depth := 1;

  /* The setting of res_cat_enum_flag='N' makes sure that the default
	where condition in UWQ is not fired. Instead the where condition
	defined by l_where_clause is fired 	*/

-- Creation of My Node. All SR assigned directly to the Resource.

  open seed_cursor;

  loop
     fetch seed_cursor into l_node_label,l_view_name,l_where_clause,l_data_source,
     l_node_query,l_cursor_sql,l_node_id,l_res_cat_enum_flag,l_level,l_parent_id;

     exit when seed_cursor%NOTFOUND;

     if l_node_id < 1000 or (l_parent_id < 1000  and l_parent_id > 0) then
        -- This means that the node is a seeded node or a child node of
        -- another seeded node.

        l_node_counter := l_node_counter + 1;

        begin
           select node_label into l_node_label from cs_sr_uwq_nodes_tl
           where node_id=l_node_id and language=userenv('LANG');
        exception
           when NO_DATA_FOUND then
              l_node_label:='Error: No Label ';
        end;

        l_bind_list(1).bind_var_name  := ':owner_id';
        l_bind_list(1).bind_var_value := p_resource_id;
        l_bind_list(1).bind_var_data_type :='NUMBER';

        if (l_parent_id < 1000  and l_parent_id > 0) then
          -- This means that the node is a child node and its parent
          -- is a seeded node. So the child node will inherit the where
          -- condition of the parent.

           begin
              l_parent_where_clause := null;
              select where_clause into l_parent_where_clause from cs_sr_uwq_nodes_b
              where node_id=l_parent_id ;
           exception
           when NO_DATA_FOUND then
              l_parent_where_clause :=' incident_id = -1  ';
           end;
           if l_where_clause is not null then
              l_where_clause := l_parent_where_clause ||' AND '||l_where_clause;
           else
              l_where_clause := l_parent_where_clause ;
           end if;

        end if; -- End of if at l_parent_id

        l_sr_list(l_node_counter).node_label := l_node_label;
        l_sr_list(l_node_counter).view_name := l_view_name;
        l_sr_list(l_node_counter).data_source := l_data_source;
        l_sr_list(l_node_counter).media_type_id := '';
        l_sr_list(l_node_counter).where_clause := l_where_clause;
        l_sr_list(l_node_counter).res_cat_enum_flag := l_res_cat_enum_flag;
        l_sr_list(l_node_counter).node_type := 10;
        l_sr_list(l_node_counter).hide_if_empty := '';
        l_sr_list(l_node_counter).node_depth := l_level+1;
        return_value := ieu_pub.set_bind_var_data(l_bind_list);
        l_sr_list(l_node_counter).bind_vars := return_value;

        begin
        -- For Each of the SINGLE defined nodes first check if there
        -- exist any CURSOR defined child nodes. If so execute the
        -- SQL and build the child nodes.

           select node_label,node_view,cursor_key_col,data_source,
                  node_query,cursor_sql,uwq_b.node_id,res_cat_enum_flag
           into   l_node_label,l_view_name,l_cursor_key_col,l_data_source,
                  l_node_query,l_cursor_sql,l_node_id,l_res_cat_enum_flag
           from cs_sr_uwq_nodes_b uwq_b, cs_sr_uwq_nodes_tl uwq_tl
           where uwq_b.node_id = uwq_tl.node_id
           and   uwq_tl.language = userenv('LANG')
           and parent_id = l_node_id and enabled_flag='Y'
           and node_query = 'CURSOR' ;

           if l_cursor_sql is not null then

             l_node_counter := l_node_counter + 1;
             l_sr_list(l_node_counter).node_label := l_node_label;
             l_sr_list(l_node_counter).view_name := l_view_name;
             l_sr_list(l_node_counter).data_source := l_data_source;
             l_sr_list(l_node_counter).media_type_id := '';
             l_sr_list(l_node_counter).where_clause := ' incident_id = -101 ';
             l_sr_list(l_node_counter).res_cat_enum_flag := 'N';
             l_sr_list(l_node_counter).node_type := 10;
             l_sr_list(l_node_counter).hide_if_empty := '';
             l_sr_list(l_node_counter).node_depth := l_level+2;

             v_cursorid := dbms_sql.open_cursor;
             dbms_sql.parse(v_cursorid, l_cursor_sql, DBMS_SQL.V7);
             dbms_sql.define_column(v_cursorid, 1, l_meaning, 360);--5579863
             dbms_sql.define_column(v_cursorid, 2, l_id_of_value);
             v_dummy := dbms_sql.execute(v_cursorid);

             loop
                if dbms_sql.fetch_rows(v_cursorid) = 0 then
                   exit;
                end if;

                dbms_sql.column_value(v_cursorid, 1, l_meaning);
                dbms_sql.column_value(v_cursorid, 2, l_id_of_value);
                l_where_clause := l_cursor_key_col||' = :seedsubbindvalue';
                l_node_counter := l_node_counter + 1;

		l_bind_list(1).bind_var_name  := ':seedsubbindvalue';
		l_bind_list(1).bind_var_value := l_id_of_value;
		l_bind_list(1).bind_var_data_type :='NUMBER';

                l_sr_list(l_node_counter).node_label := l_meaning;
                l_sr_list(l_node_counter).view_name := l_view_name;
                l_sr_list(l_node_counter).data_source := l_data_source;
                l_sr_list(l_node_counter).media_type_id := '';
                l_sr_list(l_node_counter).where_clause := l_where_clause;
                l_sr_list(l_node_counter).res_cat_enum_flag := l_res_cat_enum_flag;

                l_sr_list(l_node_counter).node_type := 12;

                l_sr_list(l_node_counter).hide_if_empty := '';
                l_sr_list(l_node_counter).node_depth := l_level+3;

	        return_value := ieu_pub.set_bind_var_data(l_bind_list);
	        l_sr_list(l_node_counter).bind_vars := return_value;

             end loop;

             dbms_sql.close_cursor(v_cursorid);

          end if;

       exception
          when NO_DATA_FOUND then
             null;
       end;	-- End of Begin at CURSOR based sub Nodes.

     end if; --- End of check for node id and parent id.

  end loop;  --- End of main loop for seed cursor

  close seed_cursor;

-- Creation of Team Node. All SR assigned directly to the Team(s) of the Resource.
-- The first node in the Team Node is a dummy

  open cur_seed_cursor;

  loop
     fetch cur_seed_cursor into l_node_label,l_view_name,
               l_where_clause,l_data_source,
               l_node_query,l_cursor_sql,l_cursor_key_col,
               l_node_id,l_res_cat_enum_flag;

     exit when cur_seed_cursor%NOTFOUND;

     if l_cursor_sql is not null then

        l_bind_list(1).bind_var_name  := ':owner_id';
        l_bind_list(1).bind_var_value := p_resource_id;
        l_bind_list(1).bind_var_data_type :='NUMBER';

        l_node_counter := l_node_counter + 1;
        l_sr_list(l_node_counter).node_label := l_node_label;
        l_sr_list(l_node_counter).view_name := l_view_name;
        l_sr_list(l_node_counter).data_source := l_data_source;
        l_sr_list(l_node_counter).media_type_id := '';
        l_sr_list(l_node_counter).where_clause := l_where_clause;
        l_sr_list(l_node_counter).res_cat_enum_flag := 'N';
        l_sr_list(l_node_counter).node_type := 10;
        l_sr_list(l_node_counter).hide_if_empty := '';
        l_sr_list(l_node_counter).node_depth := 2;
        return_value := ieu_pub.set_bind_var_data(l_bind_list);
        l_sr_list(l_node_counter).bind_vars := return_value;

        v_cursorid := dbms_sql.open_cursor;
        dbms_sql.parse(v_cursorid, l_cursor_sql, DBMS_SQL.V7);
        dbms_sql.define_column(v_cursorid, 1, l_meaning, 360);--5579863
        dbms_sql.define_column(v_cursorid, 2, l_id_of_value);
        dbms_sql.bind_variable(v_cursorid, ':OWNER_ID', p_resource_id);
        v_dummy := dbms_sql.execute(v_cursorid);

        loop
           if dbms_sql.fetch_rows(v_cursorid) = 0 then
              exit;
           end if;
           dbms_sql.column_value(v_cursorid, 1, l_meaning);
           dbms_sql.column_value(v_cursorid, 2, l_id_of_value);
           l_where_clause := l_cursor_key_col||' = :bindvalue';
           l_node_counter := l_node_counter + 1;

           l_bind_list(1).bind_var_name  := ':bindvalue';
           l_bind_list(1).bind_var_value := l_id_of_value;
           l_bind_list(1).bind_var_data_type :='NUMBER';

           l_sr_list(l_node_counter).node_label := l_meaning;
           l_sr_list(l_node_counter).view_name := l_view_name;
           l_sr_list(l_node_counter).data_source := l_data_source;
           l_sr_list(l_node_counter).media_type_id := '';
           l_sr_list(l_node_counter).where_clause := l_where_clause;
           l_sr_list(l_node_counter).res_cat_enum_flag := l_res_cat_enum_flag;
           l_sr_list(l_node_counter).node_type := 12;
           l_sr_list(l_node_counter).hide_if_empty := '';
           l_sr_list(l_node_counter).node_depth := 3;

           return_value := ieu_pub.set_bind_var_data(l_bind_list);
           l_sr_list(l_node_counter).bind_vars := return_value;
        end loop;

        dbms_sql.close_cursor(v_cursorid);

     end if;   	-- End of if at cursor_sql is not null
  end loop; 	-- End of loop for cur_seed_cursor

--- Start of personalized single,cursor nodes.
-- This section of code queries the table cs_sr_uwq_nodes_b / tl for all
-- personalized nodes.

  open node_cursor;
  loop

     fetch node_cursor into l_node_label,
        l_view_name,n_where_clause,l_data_source,l_level,
        l_node_query,l_cursor_sql,l_node_id,l_res_cat_enum_flag;
     exit when node_cursor%notfound;

     l_node_counter := l_node_counter + 1;

     begin
        select node_label into l_node_label from cs_sr_uwq_nodes_tl
        where node_id=l_node_id and language=userenv('LANG');
     exception
        when NO_DATA_FOUND then
           l_node_label:='Error: No Label ';
     end;

     l_sr_list(l_node_counter).node_label := l_node_label;
     l_sr_list(l_node_counter).view_name := l_view_name;
     l_sr_list(l_node_counter).data_source := l_data_source;
     l_sr_list(l_node_counter).media_type_id := '';
     l_sr_list(l_node_counter).where_clause := n_where_clause;
     l_sr_list(l_node_counter).res_cat_enum_flag := l_res_cat_enum_flag;
     l_sr_list(l_node_counter).node_type := 10;
     l_sr_list(l_node_counter).hide_if_empty := '';
     l_sr_list(l_node_counter).node_depth := l_level+1;

     if instr(lower(n_where_clause), ':owner_id') <> 0 then
       l_bind_list(1).bind_var_name  := ':owner_id';
       l_bind_list(1).bind_var_value := p_resource_id;
       l_bind_list(1).bind_var_data_type :='NUMBER';
       return_value := ieu_pub.set_bind_var_data(l_bind_list);
       l_sr_list(l_node_counter).bind_vars := return_value;
     end if;

     begin
     -- For Each of the SINGLE defined nodes first check if there
     -- exist any CURSOR defined child nodes. If so execute the
     -- SQL and build the child nodes.
        select node_label,node_view,cursor_key_col,data_source,
               node_query,cursor_sql,uwq_b.node_id
	       , res_cat_enum_flag
        into   l_node_label,l_view_name,l_cursor_key_col,l_data_source,
               l_node_query,l_cursor_sql,l_node_id
	       , l_res_cat_enum_flag
        from cs_sr_uwq_nodes_b uwq_b, cs_sr_uwq_nodes_tl uwq_tl
        where uwq_b.node_id = uwq_tl.node_id
        and   uwq_tl.language = userenv('LANG')
        and parent_id = l_node_id and enabled_flag='Y'
        and node_query = 'CURSOR' ;

        if l_cursor_sql is not null then

          l_node_counter := l_node_counter + 1;
          l_sr_list(l_node_counter).node_label := l_node_label;
          l_sr_list(l_node_counter).view_name := l_view_name;
          l_sr_list(l_node_counter).data_source := l_data_source;
          l_sr_list(l_node_counter).media_type_id := '';
          l_sr_list(l_node_counter).where_clause := ' incident_id = -1 ';
          l_sr_list(l_node_counter).res_cat_enum_flag := 'N';
          l_sr_list(l_node_counter).node_type := 10;
          l_sr_list(l_node_counter).hide_if_empty := '';
          l_sr_list(l_node_counter).node_depth := l_level+2;

           v_cursorid := dbms_sql.open_cursor;
           dbms_sql.parse(v_cursorid, l_cursor_sql, DBMS_SQL.V7);
           dbms_sql.define_column(v_cursorid, 1, l_meaning, 360);--5579863
           dbms_sql.define_column(v_cursorid, 2, l_id_of_value);
           v_dummy := dbms_sql.execute(v_cursorid);

           loop
              if dbms_sql.fetch_rows(v_cursorid) = 0 then
                 exit;
              end if;

              dbms_sql.column_value(v_cursorid, 1, l_meaning);
              dbms_sql.column_value(v_cursorid, 2, l_id_of_value);
	      l_where_clause := l_cursor_key_col||' = :customsubbindvalue';
              l_node_counter := l_node_counter + 1;

	      l_bind_list(1).bind_var_name  := ':customsubbindvalue';
	      l_bind_list(1).bind_var_value := l_id_of_value;
	      l_bind_list(1).bind_var_data_type :='NUMBER';

              l_sr_list(l_node_counter).node_label := l_meaning;
              l_sr_list(l_node_counter).view_name := l_view_name;
              l_sr_list(l_node_counter).data_source := l_data_source;
              l_sr_list(l_node_counter).media_type_id := '';
              l_sr_list(l_node_counter).where_clause := l_where_clause;
              l_sr_list(l_node_counter).res_cat_enum_flag := l_res_cat_enum_flag;
              l_sr_list(l_node_counter).node_type := 12;
              l_sr_list(l_node_counter).hide_if_empty := '';
              l_sr_list(l_node_counter).node_depth := l_level+3;

	      return_value := ieu_pub.set_bind_var_data(l_bind_list);
	      l_sr_list(l_node_counter).bind_vars := return_value;
           end loop;

           dbms_sql.close_cursor(v_cursorid);

        end if;

     exception
        when NO_DATA_FOUND then
           null;
     end;	-- End of Begin at CURSOR based sub Nodes.

  end loop;
  close node_cursor;

  ieu_pub.add_uwq_node_data
           (p_resource_id,
            p_sel_enum_id,
            l_sr_list );

exception
   when OTHERS then

  --prayadur 29-Sep-05 Commented the code below and added
  --the following 2 lines for Bug 4434093.
     -- l_where_clause := sqlerrm;
	 ROLLBACK TO start_cs_enum;
	 RAISE;

end enumerate_sr_nodes;

procedure refresh_sr_nodes
  (p_resource_id in number,
   p_node_id in number,
   p_count out NOCOPY number) is

   sr_count number;
   n_count  number;
   l_node_type  number;
   l_node_count_view varchar2(50);

   l_node_detail_record IEU_PUB.NodeDetailRecord;
   s_sql_statement varchar2(4000);
   s_unbound_stat varchar2(4000);

begin

/* Count refresh is done W.R.T. the type of the Node. The root node
   is of the type '0'. All seeded nodes are of type '10'. All run time
   generated nodes are of type '12'.

   Service Request       	Type 0
   |
   ---My Service Request	Type 10
   |
   ---My Groups  		Type 10
     |
     ----Group 1		Type 12
     |
     ----Group 2		Type 12
   |
   ---My Teams 			Type 10
     |
     ----Team 1			Type 12
     |
     ----Team 2			Type 12
   |
   ---Group Owned  		Type 10
   |
   ---Team Owned		Type 10

   For the Refresh function logic all Seeded and Root nodes will use the
   new Count views. Since the runtime nodes can be set to different
   where clauses and may use the columns from the regular view we
   cannot use the count view as they are just a subset.
*/

   sr_count := 0;

   IEU_PUB.GET_UWQ_NODE_DETAILS(p_resource_id, p_node_id, l_node_detail_record);

   if l_node_detail_record.node_type = 0 then

      s_sql_statement := ' begin select count(1) into :n_count from cs_sr_uwq_emp_count_v where resource_id = :owner_id;  end; ';

      execute immediate s_sql_statement
      using out n_count, in p_resource_id;

      sr_count := sr_count + n_count;

      select count(1) into n_count
      from cs_sr_uwq_group_count_v
      where resource_id in ( select distinct group_id from jtf_rs_group_members  a
                             where a.resource_id = p_resource_id
                             and a.resource_id = p_resource_id
                             and a.resource_id is not null
                             and nvl(a.delete_flag,'N') <> 'Y')
      and resource_type='RS_GROUP'
      and (owner_id is null  or owner_id <> p_resource_id);

      sr_count := sr_count + n_count;

      select count(1) into n_count
      from cs_sr_uwq_team_count_v
      where resource_id in ( select distinct team_id from jtf_rs_team_members  a
                             where a.team_resource_id = p_resource_id
                             and a.team_resource_id = p_resource_id
                             and a.team_resource_id is not null
                             and nvl(a.delete_flag,'N') <> 'Y')
      and resource_type='RS_TEAM'
      and (owner_id is null  or owner_id <> p_resource_id);

      sr_count := sr_count + n_count;

    elsif l_node_detail_record.node_type = 10 then

      if l_node_detail_record.view_name = 'CS_SR_UWQ_EMPLOYEE_V' then
         l_node_count_view := 'CS_SR_UWQ_EMP_COUNT_V';
      elsif l_node_detail_record.view_name = 'CS_SR_UWQ_GROUP_V' then
         l_node_count_view := 'CS_SR_UWQ_GROUP_COUNT_V';
      elsif l_node_detail_record.view_name = 'CS_SR_UWQ_TEAM_V' then
         l_node_count_view := 'CS_SR_UWQ_TEAM_COUNT_V';
      else
         l_node_count_view := l_node_detail_record.view_name;
      end if;

      s_sql_statement := ' begin select count(1) into :n_count from '||l_node_count_view||' where '||l_node_detail_record.complete_where_clause||' ; end;';
      select replace(s_sql_statement, to_char(p_resource_id),':OWNER_ID') into s_unbound_stat from dual;

      execute immediate s_unbound_stat
      using out n_count, in p_resource_id;
      sr_count := n_count;

   elsif l_node_detail_record.node_type = 12 then

      s_sql_statement := ' begin select count(1) into :n_count from '||l_node_detail_record.view_name||' where '||l_node_detail_record.complete_where_clause||' ; end;';

      execute immediate s_sql_statement
      using out n_count;
      sr_count := n_count;
    else
      sr_count := -1;

    end if;   /* end of if at node_type */

   p_count := sr_count;
end refresh_sr_nodes;

procedure insert_row(
 p_node_id	     in number,
 p_node_view         in varchar2,
 p_node_label        in varchar2,
 p_data_source       in varchar2,
 p_media_type_id     in number,
 p_where_clause      in varchar2,
 p_res_cat_enum_flag in varchar2,
 p_node_type         in varchar2,
 p_hide_if_empty     in varchar2,
 p_node_depth        in number,
 p_parent_id         in number,
 p_node_query        in varchar2,
 p_cursor_sql        in varchar2,
 p_cursor_key_col    in varchar2,
 p_enabled_flag      in varchar2,
 p_creation_date     in date,
 p_created_by        in number,
 p_last_update_date  in date,
 p_last_updated_by   in number,
 p_last_update_login in number,
 x_node_id           out NOCOPY number,
 x_return_status     out NOCOPY varchar2) is

 l_node_id 	number;
 l_return_status varchar2(10);

begin

   l_node_id 	:=0 ;
   l_return_status := 'S';
   if p_node_id is null OR p_node_id = -1 then
      select cs_sr_uwq_nodes_s.nextval into l_node_id from dual;
   else
      l_node_id := p_node_id;
   end if;

   insert into cs_sr_uwq_nodes_b
   (node_id,
    node_view,
    data_source,
    media_type_id,
    where_clause,
    res_cat_enum_flag,
    node_type,
    hide_if_empty,
    node_depth,
    parent_id,
    node_query,
    cursor_sql,
    cursor_key_col,
    enabled_flag,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    object_version_number)
   values
   (l_node_id,
    p_node_view,
    p_data_source,
    p_media_type_id,
    p_where_clause,
    p_res_cat_enum_flag,
    p_node_type,
    p_hide_if_empty,
    p_node_depth,
    p_parent_id,
    p_node_query,
    p_cursor_sql,
    p_cursor_key_col,
    p_enabled_flag,
    p_creation_date,
    p_created_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login,
    1);

   insert into cs_sr_uwq_nodes_tl
   (node_id,
    node_label,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    language,
    source_lang)
   select
   l_node_id,
    p_node_label,
    p_creation_date,
    p_created_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login,
    l.language_code,
    userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I','B');

   x_node_id := l_node_id;
   x_return_status := l_return_status;

end insert_row;

procedure update_row(
 p_node_id           in number,
 p_object_version_number  in number,
 p_node_view         in varchar2,
 p_node_label        in varchar2,
 p_data_source       in varchar2,
 p_media_type_id     in number,
 p_where_clause      in varchar2,
 p_res_cat_enum_flag in varchar2,
 p_node_type         in varchar2,
 p_hide_if_empty     in varchar2,
 p_node_depth        in number,
 p_parent_id         in number,
 p_node_query        in varchar2,
 p_cursor_sql        in varchar2,
 p_cursor_key_col    in varchar2,
 p_enabled_flag      in varchar2,
 p_creation_date     in date,
 p_created_by        in number,
 p_last_update_date  in date,
 p_last_updated_by   in number,
 p_last_update_login in number,
 x_return_status     out NOCOPY varchar2) is

 l_object_version_number  number :=0 ;

begin
   l_object_version_number := p_object_version_number;

   select object_version_number into l_object_version_number
   from cs_sr_uwq_nodes_b where node_id = p_node_id;

   if l_object_version_number = p_object_version_number then

      update cs_sr_uwq_nodes_b set
      node_view 	= p_node_view,
      data_source	= p_data_source,
      media_type_id	= p_media_type_id,
      where_clause	= p_where_clause,
      res_cat_enum_flag	= p_res_cat_enum_flag,
      node_type		= p_node_type,
      hide_if_empty	= p_hide_if_empty,
      node_depth	= p_node_depth,
      parent_id		= p_parent_id,
      node_query	= p_node_query,
      cursor_sql	= p_cursor_sql,
      cursor_key_col	= p_cursor_key_col,
      enabled_flag	= p_enabled_flag,
      creation_date	= p_creation_date,
      created_by	= p_created_by,
      last_update_date	= p_last_update_date,
      last_updated_by	= p_last_updated_by,
      last_update_login	= p_last_update_login,
      object_version_number = p_object_version_number + 1
      where node_id = p_node_id;

      update cs_sr_uwq_nodes_tl set
      node_label 	= p_node_label,
      creation_date	= p_creation_date,
      created_by	= p_created_by,
      last_update_date	= p_last_update_date,
      last_updated_by	= p_last_updated_by,
      last_update_login	= p_last_update_login
      where node_id = p_node_id
      and userenv('LANG') in (language, source_lang);

   end if;

end update_row;

procedure validate_ivr_parameter(
 p_parameter_code    in out NOCOPY varchar2,
 p_parameter_value   in out NOCOPY varchar2,
 p_parameter_mesg    in out NOCOPY varchar2,
 p_param_action_val  in out NOCOPY varchar2,
 x_parameter_id      out NOCOPY number,
 x_parameter_flag    out NOCOPY varchar2,
 x_customer_id       out NOCOPY number,
 x_customer_type     out NOCOPY varchar2,
 x_return_status     out NOCOPY varchar2) is

 l_parameter_id            number;
 v_transposed_phone_number varchar2(60);
 v_phone_number            varchar2(60);
 v_sql_statement           varchar2(500);
 v_parameter_value_temp    varchar2(100);
 n_rec_count               number;
 v_cust_number_temp        varchar2(60);

-- Validate the Incident number.
 cursor inc_cursor is select incident_id from
 cs_incidents_all_b where incident_number = p_parameter_value;

-- Validate the RMA Number
-- This cursor will get the Inc. Number associated to
-- the RMA Number. If not found it just passes the RMA Number.
 cursor rma_cursor is
 select inc.incident_id,inc.incident_number
 from oe_order_headers_all oe,
      cs_estimate_details chg,
      cs_incidents_all_b inc
 where oe.order_number = p_parameter_value
 and oe.order_category_code in ('RETURN','MIXED')
 and oe.header_id = chg.order_header_id
 and chg.incident_id = inc.incident_id;

-- Validate the Tag Number
-- The validation is done against CSI Schema only. The
-- non-validated Tag number in CS_INCIDENTS_ALL_B cannot
-- be passed as parameter.
 cursor tag_cursor is
 select item.instance_id, item.owner_party_id,
 hzp.party_type
 from csi_item_instances item, hz_parties hzp
 where item.external_reference = p_parameter_value
 and hzp.party_id = item.owner_party_id;

-- Validate the Serial Number
 cursor serial_cursor is
 select item.instance_id, item.owner_party_id,
 hzp.party_type
 from csi_item_instances item, hz_parties hzp
 where item.serial_number = p_parameter_value
 and hzp.party_id = item.owner_party_id;

-- Validate the Contract number.
-- When a Contract number is passed as an IVR it is converted
-- to the Party Id. All Open SR for that party is queried.
 cursor contract_cursor is
 select oks.contract_id, oks.party_id,hzp.party_type
 from oks_ent_hdr_summary_v oks, hz_parties hzp
 where oks.contract_number = p_parameter_value
 and oks.party_id = hzp.party_id
 and oks.start_date_active <= sysdate
 order by oks.start_date_active DESC;

--Validate the Account Number.
 cursor account_cursor is
 select acc.cust_account_id,acc.party_id,
 party.party_type
 from hz_cust_accounts acc, hz_parties party
 where acc.account_number = p_parameter_value
 and acc.status = 'A'
 and party.party_id = acc.party_id;

--Validate the Party Number.
 cursor party_cursor is
 select party.party_id,party.party_id,
 party.party_type
 from hz_parties party
 where party_number = p_parameter_value;

--Validate the Phone Number

 cursor phone_cursor is
 select cont.contact_point_id,cont.phone,
 party.party_type
 from cs_sr_hz_cust_cont_v party, cs_sr_hz_cont_pts_p_phones_v cont
 where cont.transposed_phone_number = v_transposed_phone_number
 and cont.owner_table_id = party.party_id
 and cont.phone is not null;

--Validate the Phone Number on a CREATE_SR scenario

 cursor phone_cursor_create_sr is
 select hzc.owner_table_id,hzp.party_number,hzp.party_type
  from hz_contact_points hzc, hz_parties hzp
  where hzc.transposed_phone_number = v_transposed_phone_number
  and hzc.owner_table_id = hzp.party_id
  and hzc.owner_table_name = 'HZ_PARTIES';

begin
-- This procedure validates the IVR data using sqls.
-- It returns the Id value of the parameter if found.
-- There may not be a case where a parameter was found
-- valid but the id was not available.

   l_parameter_id := -1;
   x_parameter_flag := 'INVALID';

    if p_parameter_code = 'SR_NUMBER' then
        open inc_cursor;

        fetch inc_cursor into l_parameter_id;
        if inc_cursor%NOTFOUND then
           l_parameter_id := -1;
        else
            x_parameter_flag := 'VALID';
        end if;

        close inc_cursor;

    elsif p_parameter_code = 'SR_ACC_NUMBER' then
        open account_cursor;

        fetch account_cursor into l_parameter_id,x_customer_id,
                                  x_customer_type;
        if account_cursor%NOTFOUND then
           l_parameter_id := -1;
        else
            x_parameter_flag := 'VALID_CUSTOMER';
        end if;

        close account_cursor;

    elsif p_parameter_code = 'SR_SERIAL_NUMBER' then
        open serial_cursor;

        fetch serial_cursor into l_parameter_id,x_customer_id,
                                 x_customer_type;
        if serial_cursor%NOTFOUND then
           l_parameter_id := -1;
        else
            x_parameter_flag := 'VALID_CUSTOMER';
        end if;

        close serial_cursor;

    elsif p_parameter_code = 'SR_TAG_NUMBER' then
        open tag_cursor;

        fetch tag_cursor into l_parameter_id,x_customer_id,
                              x_customer_type;
        if tag_cursor%NOTFOUND then
           l_parameter_id := -1;
        else
            x_parameter_flag := 'VALID_CUSTOMER';
        end if;

        close tag_cursor;

    elsif p_parameter_code = 'SR_PARTY_NUMBER' then
        open party_cursor;

        fetch party_cursor into l_parameter_id,x_customer_id,
                                x_customer_type;
        if party_cursor%NOTFOUND then
           l_parameter_id := -1;
        else
            x_parameter_flag := 'VALID_CUSTOMER';
        end if;

        close party_cursor;

    elsif p_parameter_code in ('SR_PHONE_NUMBER','SR_ANI') then

        if p_parameter_value = 'NO_DATA' then
           p_parameter_value := 0;
        end if;
        p_parameter_value := nvl(p_parameter_value,0);

        v_sql_statement := ' begin select reverse(to_char('||p_parameter_value||')) into :v_transposed_phone_number from dual;  end; ';
        execute immediate v_sql_statement
        using out v_transposed_phone_number;

        if p_param_action_val in ('CREATE_SR') then
           /* When the incoming call is to create a new SR, we check if
              there exists just one customer with that phone. If so we
              shall default the customers details on the SR form. Else
              we shall just open a Blank SR form */
           open phone_cursor_create_sr;
           n_rec_count := 0;

           loop
              fetch phone_cursor_create_sr into x_customer_id,v_cust_number_temp,
                              x_customer_type;
              exit when phone_cursor_create_sr%NOTFOUND;
              n_rec_count := n_rec_count + 1;

           end loop;

           close phone_cursor_create_sr;

           if n_rec_count = 0 then
              l_parameter_id := -1;
           elsif n_rec_count > 1 then
              p_parameter_mesg  := p_parameter_code||'-'||p_parameter_value||'-MULT-'||n_rec_count;
           elsif n_rec_count = 1 then
               p_parameter_mesg  := p_parameter_code||'-'||p_parameter_value;
               p_parameter_value := v_cust_number_temp;
               p_parameter_code  := 'SR_PARTY_NUMBER';
               l_parameter_id    := x_customer_id;
               x_parameter_flag  := 'VALID_CUSTOMER';
           end if;

        else
           /* For all other incoming calls with Phone Number or ANI we shall do
              a regular Call to Inquiry scenario */

           open phone_cursor;

           fetch phone_cursor into l_parameter_id,v_phone_number,
                              x_customer_type;
           if phone_cursor%NOTFOUND then
              l_parameter_id := -1;
           else
               p_parameter_mesg  := p_parameter_code||'-'||p_parameter_value;
               p_parameter_value := v_phone_number;
               x_parameter_flag  := 'VALID_CUSTOMER';
           end if;

           close phone_cursor;

        end if;  /* End of if at p_param_action_val */

    elsif p_parameter_code = 'SR_RMA_NUMBER' then
        open rma_cursor;

        fetch rma_cursor into l_parameter_id,v_parameter_value_temp;
        if rma_cursor%NOTFOUND then
           l_parameter_id := -1;
           v_parameter_value_temp := null;
        else
            x_parameter_flag := 'VALID_RMA';
            p_parameter_mesg := p_parameter_code||' '||p_parameter_value;
            p_parameter_code := 'SR_NUMBER';
            p_parameter_value:= v_parameter_value_temp;
/* This code above converts the RMA Parameter into the corresponding SR Number.
   This opens the main SR form automatically. The Original values of
   RMA number and the code are put into the message parameter */

        end if;

        close rma_cursor;

    elsif p_parameter_code = 'SR_CONTRACT_NUMBER' then
        open contract_cursor;

        fetch contract_cursor into l_parameter_id,x_customer_id,
                              x_customer_type;
        if contract_cursor%NOTFOUND then
           l_parameter_id := -1;
        else
            x_parameter_flag := 'VALID_CUSTOMER';
        end if;

        close contract_cursor;

    end if;

   x_parameter_id := l_parameter_id;
   x_return_status := 'S';

exception
  when OTHERS then
     x_return_status := 'U';
     x_parameter_id  := -1;
     x_parameter_flag := 'INVALID';

end;

procedure interpret_service_keys(
 v_service_key       in varchar2,
 v_service_key_value in out NOCOPY varchar2,
 p_cust_id           in number,
 p_cust_account_id   in number,
 p_phone_id          in number,
 x_parameter_code    out NOCOPY varchar2,
 x_return_status     out NOCOPY varchar2) is

--Retrieve the Account Number.
 cursor account_cursor is
 select acc.account_number
 from hz_cust_accounts acc
 where acc.cust_account_id = p_cust_account_id
 and acc.status = 'A';

--Retrieve the Party Number.
 cursor party_cursor is
 select party_number
 from hz_parties
 where party_id = p_cust_id;

begin
   x_return_status := 'S';

   if v_service_key = 'SERVICE_REQUEST_NUMBER' then
      x_parameter_code := 'SR_NUMBER';

   elsif v_service_key = 'CONTRACT_NUMBER' then
      x_parameter_code := 'SR_CONTRACT_NUMBER';

   elsif v_service_key = 'SERIAL_NUMBER' then
      x_parameter_code := 'SR_SERIAL_NUMBER';

   elsif v_service_key = 'EXTERNAL_REFERENCE' then
      x_parameter_code := 'SR_TAG_NUMBER';

   elsif v_service_key = 'RMA_NUMBER' then
      x_parameter_code := 'SR_RMA_NUMBER';

   else
      if nvl(p_cust_account_id,0) <>0 then
         x_parameter_code := 'SR_ACC_NUMBER';
         open account_cursor;

         fetch account_cursor into v_service_key_value;
         if account_cursor%NOTFOUND then
            v_service_key_value := '-1';
        end if;

        close account_cursor;

      elsif nvl(p_cust_id,0) <>0 then
         x_parameter_code := 'SR_PARTY_NUMBER';
         open party_cursor;

         fetch party_cursor into v_service_key_value;
         if party_cursor%NOTFOUND then
            v_service_key_value := '-1';
        end if;

        close party_cursor;

      elsif nvl(p_phone_id,0) <>0 then
         x_parameter_code := 'SR_PHONE_NUMBER';

      else
         x_parameter_code := 'NO_DATA';

      end if;   -- End of if Acc, Cust, Phone.
   end if;      -- End of if v_service_key.

end ;

procedure validate_security(
 p_ivr_data_key     in varchar2,
 p_ivr_data_value   in varchar2,
 p_table_of_agents  in out NOCOPY system.CCT_AGENT_RESP_APP_ID_NST,
 x_return_status    out NOCOPY varchar2) is

 lx_msg_count number;
 lx_msg_data  varchar2(2000);
 lx_return_status varchar2(1);

 n_agent_id number;
 n_resp_id number;
 n_user_id number;
 n_old_resp_id number;
 n_app_id number;
 n_old_app_id number;
 n_incident_id number;
 v_security_flag varchar2(1);
 v_resource_err varchar2(1);
 v_process_flag varchar2(1) ;
 v_sec_setting varchar2(30);

 cursor sec_value is select sr_agent_security
 from cs_system_options where rownum = 1;

 cursor sr_cursor is select incident_id from
 cs_incidents_all_b where incident_number = p_ivr_data_value;

 cursor sr_type_sec_chk is select 'Y' from
 cs_sr_type_mapping where incident_type_id = n_incident_id
                    and   responsibility_id= n_resp_id
                    and   sysdate between
                       nvl(start_date,sysdate) and  nvl(end_date,sysdate);

begin
   x_return_status := 'S';
   n_old_resp_id := -1;
   n_resp_id     := -1;
   n_old_app_id := -1;
   n_app_id     := -1;
   v_process_flag := 'Y';

  open sr_cursor;
  fetch sr_cursor into n_incident_id;

  if sr_cursor%NOTFOUND then
     v_process_flag := 'N';
  end if;
  close sr_cursor;

  if v_process_flag = 'Y' then
     for i IN 1..p_table_of_agents.count
     loop
       n_agent_id := p_table_of_agents(i).agent_id;
       BEGIN
         -- Deriving the user id for resource. If there is no user id associated
         -- with the resource the security_yn_flag will be set to N. If the
         -- resource is associated with more that one user then security_yn_flag
         -- will be set to N.

         SELECT user_id
         INTO n_user_id
         FROM jtf_rs_resource_extns
         WHERE resource_id = n_agent_id;

         v_resource_err := 'N';
       EXCEPTION
       -- Setting the v_security_flag to N because it may have the value of
       -- previous record.
       WHEN NO_DATA_FOUND THEN
         v_resource_err := 'Y';
         v_security_flag := 'N';
       WHEN TOO_MANY_ROWS THEN
         v_resource_err := 'Y';
         v_security_flag := 'N';
       WHEN OTHERS THEN
         v_resource_err := 'Y';
         v_security_flag := 'N';
       END;

       n_resp_id  := p_table_of_agents(i).responsibility_id;
       n_app_id   := p_table_of_agents(i).application_id;

       if (n_old_resp_id <> n_resp_id OR n_old_app_id <> n_app_id) then

         -- When the responsibility id changes the security function
         -- is called to check if the responsibilty has access to
         -- to the SR.
         -- Set the CS application context for the responsibility.
         -- cs_sr_security_context.set_sr_security_context('SRTYPE_ID', n_incident_id);

         -- Call Sec function(n_app_id, p_ivr_data_value);

         v_security_flag := 'N';

         IF nvl(v_resource_err,'N') = 'N' THEN
           fnd_global.apps_initialize(
                                user_id      => n_user_id,
                                resp_id      => n_resp_id,
                                resp_appl_id => n_app_id
                            );
           cs_sr_security_context.set_sr_security_context('RESP_ID', n_resp_id);
           cs_sr_security_context.set_sr_security_context('APPL_ID', n_app_id);

           cs_sr_security_grp.validate_user_responsibility
               (  p_api_version            => NULL,
                  p_init_msg_list          => fnd_api.g_true,
                  p_commit                 => fnd_api.g_true,
                  p_incident_id            => n_incident_id,
                  x_resp_access_status     => v_security_flag,
                  x_return_status          => lx_return_status,
                  x_msg_count              => lx_msg_count,
                  x_msg_data               => lx_msg_data);

           if (lx_return_status <> fnd_api.g_ret_sts_success) then
             v_security_flag := 'N';
           end if;

           n_old_resp_id := n_resp_id;
           n_old_app_id  := n_app_id;
         end if; -- Resource error check

       end if; -- Check if resp or appl id changed

       p_table_of_agents(i).security_yn_flag := v_security_flag;
       v_resource_err := null;
     end loop;

  elsif v_process_flag = 'N' then
     for i IN 1..p_table_of_agents.count loop
       p_table_of_agents(i).security_yn_flag := 'Y';
     end loop;
  end if; -- End of if at v_process_flag

end;

procedure start_media_item( p_resp_appl_id in number,
                            p_resp_id      in number,
                            p_user_id      in number,
                            p_login_id     in number,
                            x_return_status out nocopy  varchar2,
                            x_msg_count     out nocopy  number,
                            x_msg_data      out nocopy  varchar2,
                            x_media_id      out nocopy  number,
			    p_outbound_dnis in varchar2 DEFAULT NULL, -- Added by vpremach for Bug 9499153
	  		    p_outbound_ani in varchar2 DEFAULT NULL   -- Added by vpremach for Bug 9499153
			     ) is

   v_true             varchar2(5);
   v_false            varchar2(5);
   v_ret_sts_failure  varchar2(1);
   p_media_rec        JTF_IH_PUB.media_rec_type;

begin

   v_true               := cs_core_util.get_g_true;
   v_false              := cs_core_util.get_g_false;
   v_ret_sts_failure    := 'E';

   p_media_rec.media_id := NULL;
   p_media_rec.media_item_type := 'TELEPHONE';
   p_media_rec.start_date_time := sysdate;
   p_media_rec.direction := 'OUTBOUND';
   p_media_rec.ani  := p_outbound_ani ; -- Added by vpremach for Bug 9499153
   p_media_rec.dnis := p_outbound_dnis; -- Added by vpremach for Bug 9499153


   jtf_ih_pub.open_mediaitem( p_api_version     => 1.0,
                              p_init_msg_list   => v_true,
                              p_commit          => v_true,
                              p_resp_appl_id    => p_resp_appl_id,
                              p_resp_id         => p_resp_id,
                              p_user_id         => p_user_id,
                              p_login_id        => p_login_id,
                              x_return_status   => x_return_status,
                              x_msg_count       => x_msg_count,
                              x_msg_data        => x_msg_data,
                              p_media_rec       => p_media_rec,
                              x_media_id        => x_media_id);

   if x_media_id is null then
      x_return_status := v_ret_sts_failure;
   end if;

end start_media_item;



 -- ===========================================================
  -- PRAYADUR 04/28/2004
  -- Added the procedure SR_UWQ_NONMEDIA_ACTIONS for Bug 3357706.
  -- This is a Non media Action function used to pass the
  -- Default_Tab Parameter to SR form. This Function is mapped
  -- to the Action object Code 'SR' and it invokes the SR form
  -- with Default Tab as Tasks.
  -- ===========================================================

PROCEDURE   SR_UWQ_NONMEDIA_ACTIONS(p_ieu_action_data   IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
              x_action_type OUT NOCOPY NUMBER,
              x_action_name OUT NOCOPY varchar2,
              x_action_param OUT NOCOPY varchar2,
              x_msg_name OUT NOCOPY varchar2,
              x_msg_param OUT NOCOPY varchar2,
              x_dialog_style OUT NOCOPY number,
              x_msg_appl_short_name OUT NOCOPY varchar2)  IS


  l_Req_Number Varchar2(64);
  l_Task_id NUMBER;

  CURSOR SR_Cur is
         Select  Inc.Incident_number
         from Jtf_tasks_b Tsk,  CS_incidents_all_b Inc
         where Tsk.Task_id=l_Task_id
         and Inc.Incident_Id=Tsk.source_object_id;


BEGIN

   FOR i IN p_ieu_action_data.first.. p_ieu_action_data.last

   LOOP

      IF ( upper(p_ieu_action_data(i).param_name) = 'TASK_ID' ) then

          l_task_id := p_ieu_action_data(i).param_value;

      END IF;

   END LOOP;

   IF l_task_id IS NOT NULL THEN

        OPEN SR_cur;

        FETCH SR_Cur INTO l_Req_Number;

        IF SR_cur%NOTFOUND THEN

            NULL;

        ELSE

            x_action_param := 'REQUEST_NUMBER="' || l_Req_Number||'"' ;

            x_action_param :=x_action_param ||'DEFAULT_TAB="TASKS"';
-- For Bug 6901209
            x_action_param :=x_action_param ||'REQUEST_TASK_ID="' || l_task_id||'"';

        END IF;

        CLOSE SR_cur;

   END IF;

   x_action_name := 'CSXSRISR' ;
   x_action_type := 1;
   x_msg_name := 'NULL' ;
   x_msg_param := 'NULL' ;
   x_dialog_style := 1;
   x_msg_appl_short_name := 'NULL' ;


EXCEPTION
    WHEN OTHERS THEN
        NULL;

END SR_UWQ_NONMEDIA_ACTIONS ;


procedure create_service_request(
    p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2,
    p_commit                 IN    VARCHAR2,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER,
    p_resp_id                IN    NUMBER,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER,
    p_org_id                 IN    NUMBER,
    p_request_id             IN    NUMBER,
    p_request_number         IN    VARCHAR2,
    sr_type                  IN    VARCHAR2,
    summary                  IN    VARCHAR2,
    severity_id              IN    VARCHAR2,
    urgency_id               IN    VARCHAR2,
    customer_id              IN    VARCHAR2,
    customer_type            IN    VARCHAR2,
    account_id               IN    VARCHAR2,
    note_type                IN    VARCHAR2,
    note                     IN    VARCHAR2,
    -- contact_id               IN    VARCHAR2,
    -- contact_point_id         IN    VARCHAR2,
    -- primary_flag             IN    VARCHAR2,
    -- contact_point_type       IN    VARCHAR2,
    -- contact_type             IN    VARCHAR2,
    p_auto_assign            IN    VARCHAR2,
    p_auto_generate_tasks    IN    VARCHAR2,
    x_service_request_number         OUT   NOCOPY NUMBER,
    p_default_contract_sla_ind       IN    VARCHAR2,
    p_default_coverage_template_id   IN    NUMBER) is

  l_auto_generate_tasks VARCHAR2(1) := 'N';
  x_msg_index_out   NUMBER;

  subtype r_service_request_rec_type is CS_SERVICEREQUEST_PUB.service_request_rec_type;
  r_service_request_rec  r_service_request_rec_type;

  subtype t_notes_table_type is CS_ServiceRequest_PUB.notes_table;
  t_notes_table t_notes_table_type;

  subtype t_contacts_table_type is CS_ServiceRequest_PUB.contacts_table;
  t_contacts_table t_contacts_table_type;

  subtype o_sr_create_out_rec_type is CS_SERVICEREQUEST_PUB.SR_CREATE_OUT_REC_TYPE;
  o_sr_create_out_rec o_sr_create_out_rec_type;

  BEGIN
    CS_SERVICEREQUEST_PUB.initialize_rec(r_service_request_rec);

    r_service_request_rec.status_id     := '1';
    r_service_request_rec.customer_id   := customer_id;
    r_service_request_rec.caller_type := customer_type;
    r_service_request_rec.account_id    := account_id;
    r_service_request_rec.request_date  := sysdate;
    r_service_request_rec.type_id       := sr_type;
    r_service_request_rec.summary       := summary;
    r_service_request_rec.severity_id   := severity_id;
    r_service_request_rec.urgency_id    := urgency_id;
    t_notes_table(0).note               := note;
    t_notes_table(0).note_type          := note_type;
    -- t_contacts_table(0).party_id               := contact_id;
    -- t_contacts_table(0).contact_point_id       := contact_point_id;
    -- t_contacts_table(0).primary_flag           := primary_flag;
    -- t_contacts_table(0).contact_point_type     := contact_point_type;
    -- t_contacts_table(0).contact_type           := contact_type;

    if (fnd_profile.value('CS_SR_AUTO_TASK_CREATE') = 'TASK_TMPL') then
      l_auto_generate_tasks := 'Y';
    else
      l_auto_generate_tasks := 'N';
    end if;

    CS_ServiceRequest_PUB.Create_ServiceRequest(
      p_api_version              => p_api_version,
      p_init_msg_list            => p_init_msg_list,
      p_commit                   => p_commit,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_resp_appl_id             => p_resp_appl_id,
      p_resp_id                  => p_resp_id,
      p_user_id                  => p_user_id,
      p_login_id                 => p_login_id,
      p_org_id                   => p_org_id,
      p_request_id               => p_request_id,
      p_request_number           => p_request_number,
      p_service_request_rec      => r_service_request_rec,
      p_notes                    => t_notes_table,
      p_contacts                 => t_contacts_table,
      p_auto_assign              => nvl(fnd_profile.value('CS_AUTO_ASSIGN_OWNER_FORMS'),'N'),
      p_auto_generate_tasks      => l_auto_generate_tasks,
      x_sr_create_out_rec             => o_sr_create_out_rec,
      p_default_contract_sla_ind      => p_default_contract_sla_ind,
      p_default_coverage_template_id  => p_default_coverage_template_id);

    IF ( x_return_status ) = 'S' THEN
      x_service_request_number := o_sr_create_out_rec.request_number;
    END IF;

end create_service_request;


PROCEDURE Build_Solution_Text_Query(
    p_raw_text in varchar2,
    p_solution_type_id_tbl in varchar2,
    p_search_option in number,
    x_solution_text out NOCOPY varchar2)
  is
    begin
      x_solution_text := CS_KNOWLEDGE_PVT.Build_Solution_Text_Query(p_raw_text, NULL, NULL, NULL, p_search_option);
end Build_Solution_Text_Query;


FUNCTION Get_KM_Params_Str(
    solution_num in varchar2)
  return varchar2
  is
    begin
      return CS_KB_INTEG_CONSTANTS_PKG.getParameterName('SOLUTION_NUM')||'='|| solution_num ||'&'||
             CS_KB_INTEG_CONSTANTS_PKG.getParameterName('TASK_PAGE_FUNC')||'=CSZ_TASK_TEMPLATE_CR_FN'||'&'||
	     'OAPB=CS_KB_SR_BRAND';
end Get_KM_Params_Str;


END SR_UWQ_INTEG;	-- End of Package

/
