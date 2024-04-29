--------------------------------------------------------
--  DDL for Package Body FND_WF_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WF_EVENT" AS
/* $Header: afwfeveb.pls 115.6 2003/09/10 13:45:58 vshanmug ship $ */

--
-- Get_Form_Function (PUBLIC)
--   Get the form Function for a specific Workflow Item Key and Item Type.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - attribute name
-- RETURNS
--   Form Function Name


Function Get_Form_Function(wf_item_type in varchar2, wf_item_key in varchar2)
return varchar2 is

 /* cursor to get most recent activity */
 cursor curact(itype varchar2, ikey varchar2) is
  select nvl(notification_id,0), nvl(process_activity,0)
     from wf_item_activity_statuses
     where item_type = itype
        and item_key =  ikey
        and activity_status='NOTIFIED'
      order by begin_date desc, execution_time desc;

 ntf_id number;
 frm_id number;

 attribute_value varchar2(2048);

begin
     /* Get the current activity */
     open curact(wf_item_type, wf_item_key);
     fetch curact into ntf_id, frm_id;
     close curact;

     /* either a notification or a form...whoever has the non-zero id is the
winner */
     if (ntf_id <> 0) then
        select NA.text_value
           into attribute_value
           from WF_NOTIFICATION_ATTRIBUTES NA,
       WF_MESSAGE_ATTRIBUTES_VL MA,
                  WF_NOTIFICATIONS N
           where N.NOTIFICATION_ID = ntf_id
              and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
              and MA.MESSAGE_NAME = N.MESSAGE_NAME
              and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
              and MA.NAME = NA.NAME
              and MA.SUBTYPE = 'RESPOND'
              and MA.TYPE <> 'FORM'
              and MA.NAME <> 'RESULT';
     else
         select wv.text_value
            into attribute_value
            from wf_process_activities wpa,
                   wf_activities wa,
                   wf_activity_attributes waa,
                   wf_activity_attr_values wv,
                   wf_items wi
          where wpa.instance_id  = frm_id
             and wpa.activity_item_type = wa.item_type
             and wpa.activity_name = wa.name
             and waa.activity_item_type = wa.item_type
             and waa.activity_name = wa.name
             and waa.activity_version = wa.version
             and wv.process_activity_id = wpa.instance_id
             and wv.name = waa.name
             and waa.type = 'FORM'
             and wi.item_type = wf_item_type
             and wi.begin_date >= wa.begin_date
             and wi.begin_date < nvl(wa.end_date,wi.begin_date+1)
             and wi.item_key = wf_item_key;
     end if;

     return attribute_value;

exception  when OTHERS then
    if (curact%ISOPEN) then
      close curact;
    end if;

    raise;
end;

-- Raise_Table(PRIVATE)
--   Raises a Workflow. This is to be called ONLY from Forms and is used ONLY
--   because of the lack of support of object types in Forms.
--   The Param Table is a PL/SQL table which can hold up to 100 parameters.
-- IN:
--   p_event_name - event name
--   p_event_key - event key
--   p_event_date - This is not being used here but is left for consistentcy with
--                  other wf procedures. It MUST always be NULL
--   p_param_table - This IN/OUT PL/SQL table contains the parameters to pass to the wf.raise
--   p_number_params - This is the number of parameters in the above PL/SQL table
--   p_send_date - Send Date
-- NOTE
--   The PL/SQL Table has the following restrictions
--     -There must be consecutive rows in PL/SQL table starting with index 1
--     -An identical number of paramters must be returned from raise3 as are submitted to it.

Procedure raise_table(p_event_name  	 in varchar2,
                	  p_event_key        in varchar2,
                	  p_event_data       in clob default NULL,
					  p_param_table      in out nocopy Param_Table,
					  p_number_params    in NUMBER,
					  p_send_date        in date default NULL ) IS

  l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
  i number := 1;
  begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.fnd_wf_event.raise.begin',
                      'Event Name:'||p_event_name||' Event Key:'||p_event_key);
  end if;

  for i in 1..p_number_params LOOP
     l_parameter_list.extend;
     l_parameter_list(i) := wf_event.CreateParameter(p_param_table(i).Param_Name, p_param_table(i).Param_Value);
  end LOOP;

  wf_event.raise3(p_event_name, p_event_key, p_event_data, l_parameter_list, p_send_date);
  i := 1;
  for i in 1..p_number_params LOOP
    p_param_table(i).Param_Value := wf_event.getValueForParameter(p_param_table(i).Param_Name , l_parameter_list );
--    p_param_table(i).Param_Value := ('456');
  END LOOP;

END raise_table;

-- Get_Error_Name(PUBLIC)
--   Gets the Workflow Error Name
-- RETURNS
--   The Workflow Error Name
-- NOTE
--   This routine is to be used only from Forms.
--   It exists only because forms cannot fetch a package variable from a server-side package.

Function Get_Error_Name RETURN VARCHAR2 IS
BEGIN
  RETURN wf_core.error_name;
END Get_Error_Name;

-- Erase(PRIVATE)
--   Erases all traces of a workflow
-- NOTE
--   This routine is to be used only from Forms.
--   It is only here to isolate forms from WF changes.
Procedure erase(p_item_type in varchar2,
                p_item_key  in varchar2)
IS
BEGIN
  wf_item_import.erase(p_item_type,p_item_key);
END erase;

end fnd_wf_event;

/
