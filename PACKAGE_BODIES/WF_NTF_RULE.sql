--------------------------------------------------------
--  DDL for Package Body WF_NTF_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NTF_RULE" as
/* $Header: WFNRULEB.pls 120.4 2006/01/25 15:34:10 smayze noship $ */

--Variables
hashbase number:=1;
hashsize number:=512;

--APIs
function Submit_Conc_Program_RF( p_sub_guid  in            RAW,
                                 p_event     in out NOCOPY WF_EVENT_T)
                              return VARCHAR2
is
i_submit_id  	   number;
l_rule_name  	   varchar2(30);
l_msg_type   	   varchar2(30);
l_parameter_list   wf_parameter_list_t;
request_id	   varchar2(4000);
org_user_id        number;
org_resp_id        number;
org_resp_appl_id   number;

cursor c_rules is
    select distinct wnrc.message_type
    from   wf_ntf_rules wnr,
           wf_ntf_rule_criteria wnrc
    where  wnr.rule_name = l_rule_name
    and    wnr.rule_name = wnrc.rule_name;
begin
    org_user_id := fnd_global.user_id;
    org_resp_id := fnd_global.resp_id;
    org_resp_appl_id := fnd_global.resp_appl_id;

    fnd_global.apps_initialize(0, org_resp_id, org_resp_appl_id);

    l_rule_name := p_event.getEventKey();

    for v_rule in c_rules
    loop
    	i_submit_id := fnd_request.submit_request(
                       		application => 'FND',
                       		program     => 'FNDWFDCC',
                       		Start_Time  =>  NULL,
                       		Sub_Request =>  FALSE,
                       		Argument1   =>  v_rule.message_type,
                       		Argument2   =>  'OPEN',
                       		Argument3   =>  null);
        request_id := request_id || ','||to_char(i_submit_id);

    end loop;
    p_event.addParameterToList('REQUEST_ID', ltrim(request_id,','));

    commit;
    fnd_global.apps_initialize( org_user_id,org_resp_id,org_resp_appl_id);

    return 'SUCCESS';
exception
when others then
wf_core.context('WF_NTF_RULE','Submit_Conc_Program_RF',p_event.getEventName(),rawtohex(p_sub_guid));
WF_EVENT.setErrorInfo(p_event, 'ERROR');
return 'ERROR';
end Submit_Conc_Program_RF;


procedure simulate_rules (p_message_type        in  varchar2,
			  p_message_name         in  varchar2,
                          p_customization_level  in  varchar2,
                          x_custom_col_tbl       out nocopy custom_col_type)
is
  cursor custom_cols is
    select
          wnrm.column_name,
          wnr.phase,
          wnrm.attribute_name,
          wnr.customization_level,
          wnr.rule_name
     from wf_ntf_rules wnr,
          wf_ntf_rule_criteria wnrc,
          wf_ntf_rule_maps wnrm
    where wnr.rule_name = wnrc.rule_name
    and   wnr.rule_name = wnrm.rule_name
    and   wnr.status = 'ENABLED'
    and   wnrc.message_type = p_message_type
    and   ((p_customization_level is null and wnr.customization_level <> 'C')
          or wnr.customization_level = p_customization_level)
    and   exists (select null from wf_message_attributes wma
                  where wma.message_type = p_message_type
		  and  (wma.message_name = p_message_name or p_message_name is null)
		  and  wma.name = wnrm.attribute_name)
    order by wnrm.column_name, wnr.phase desc;

   cursor mesg_attr1(aname varchar2) is
    select display_name
      from wf_message_attributes_tl
     where message_type = p_message_type
       and message_name = p_message_name
       and name = aname
       and language = userenv('LANG');

   cursor mesg_attr_all(aname varchar2) is
    select distinct display_name
      from wf_message_attributes_tl
     where message_type = p_message_type
       and name = aname
       and language = userenv('LANG');

   idx      number;

begin
   x_custom_col_tbl.delete;
   for c in custom_cols
   loop
      -- column name is unique within the same rule
      -- Hash Size 512 (2^9) must be large enough to prevent collision

      idx := dbms_utility.get_hash_value(c.column_name, hashbase, hashsize);
      if (x_custom_col_tbl.exists(idx)) then
         x_custom_col_tbl(idx).override            := 'Y';
      else
         x_custom_col_tbl(idx).rule_name           := c.rule_name;
         x_custom_col_tbl(idx).column_name         := c.column_name;
         x_custom_col_tbl(idx).attribute_name      := c.attribute_name;
         x_custom_col_tbl(idx).phase               := c.phase;
         x_custom_col_tbl(idx).customization_level := c.customization_level;
         x_custom_col_tbl(idx).override            := 'N';

         if (p_message_name is null) then
            for a in mesg_attr_all(c.attribute_name)
            loop
               if (x_custom_col_tbl(idx).display_name is null) then
                  x_custom_col_tbl(idx).display_name := a.display_name;
               else
                  x_custom_col_tbl(idx).display_name :=
                    x_custom_col_tbl(idx).display_name||', '||a.display_name;
               end if;
            end loop;
         else
            for a in mesg_attr1(c.attribute_name)
            loop
               x_custom_col_tbl(idx).display_name := a.display_name;
            end loop;
         end if;
      end if;
   end loop;

exception
when others then
 wf_core.context('WF_NTF_RULE','Simulate', p_message_type, p_message_name, p_customization_level);
 raise;
end simulate_rules;

end WF_NTF_RULE;


/
