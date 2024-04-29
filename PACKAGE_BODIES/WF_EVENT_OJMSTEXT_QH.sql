--------------------------------------------------------
--  DDL for Package Body WF_EVENT_OJMSTEXT_QH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_OJMSTEXT_QH" as
/* $Header: wfjmstxb.pls 120.3.12010000.2 2009/03/20 19:59:56 alepe ship $ */

DATE_MASK          constant varchar2(21) := 'YYYY/MM/DD HH24:MI:SS';
DEFAULT_PRIORITY   constant int          := 100;

-- reserved Business Event System parameter names must begin with 'BES_'

PRIORITY           constant varchar2(30) := 'BES_PRIORITY';
SEND_DATE          constant varchar2(30) := 'BES_SEND_DATE';
RECEIVE_DATE       constant varchar2(30) := 'BES_RECEIVE_DATE';
CORRELATION_ID     constant varchar2(30) := 'BES_CORRELATION_ID';
EVENT_NAME         constant varchar2(30) := 'BES_EVENT_NAME';
EVENT_KEY          constant varchar2(30) := 'BES_EVENT_KEY';
FROM_AGENT         constant varchar2(30) := 'BES_FROM_AGENT';
TO_AGENT           constant varchar2(30) := 'BES_TO_AGENT';
ERROR_SUBSCRIPTION constant varchar2(30) := 'BES_ERROR_SUBSCRIPTION';
ERROR_MESSAGE      constant varchar2(30) := 'BES_ERROR_MESSAGE';
ERROR_STACK        constant varchar2(30) := 'BES_ERROR_STACK';
PAYLOAD_OBJECT     constant varchar2(30) := 'BES_PAYLOAD_OBJECT';

-- procedures to emulate the native aq$_jms_text_message methods available in RDBMS 9.2

procedure set_type(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                   type               in            varchar)
is
begin
   if(p_jms_text_message.header is null) then
      p_jms_text_message.header := sys.aq$_jms_header(null, null, null, null, null, 0, null);
   end if;

   p_jms_text_message.header.type := type;
end set_type;

procedure set_userid(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                     userid             in            varchar)
is
begin
   if(p_jms_text_message.header is null) then
      p_jms_text_message.header := sys.aq$_jms_header(null, null, null, null, null, 0, null);
   end if;

   p_jms_text_message.header.userid := userid;
end set_userid;

procedure set_appid(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                    appid              in            varchar)
is
begin
   if(p_jms_text_message.header is null) then
      p_jms_text_message.header := sys.aq$_jms_header(null, null, null, null, null, 0, null);
   end if;

   p_jms_text_message.header.appid := appid;
end set_appid;

procedure set_groupid(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                      groupid            in            varchar)
is
begin
   if(p_jms_text_message.header is null) then
      p_jms_text_message.header := sys.aq$_jms_header(null, null, null, null, null, 0, null);
   end if;

   p_jms_text_message.header.groupid := groupid;
end set_groupid;

procedure set_groupseq(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                       groupseq           in            int)
is
begin
   if(p_jms_text_message.header is null) then
      p_jms_text_message.header := sys.aq$_jms_header(null, null, null, null, null, 0, null);
   end if;

   p_jms_text_message.header.groupseq := groupseq;
end set_groupseq;

procedure set_replyto(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                      replyto            in            sys.aq$_agent)
is
begin
   if(p_jms_text_message.header is null) then
      p_jms_text_message.header := sys.aq$_jms_header(null, null, null, null, null, 0, null);
   end if;

   p_jms_text_message.header.replyto := replyto;
end set_replyto;

procedure lookup_property_name(properties        in out nocopy sys.aq$_jms_userproparray,
                               new_property_name in            varchar)
is
begin
   if(new_property_name is null) then
--      dbms_sys_error.raise_system_error(-24192);

      raise_application_error(-20192, 'property name is null');
null;
   end if;

   for i in properties.first .. properties.last loop
      if(properties(i).name = new_property_name) then
--         dbms_sys_error.raise_system_error(-24191, new_property_name);

         raise_application_error(-20191, 'property name already exists: ' || new_property_name);
      end if;
   end loop;
end lookup_property_name;

procedure set_int_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                           property_name      in            varchar,
                           property_value     in            int)
is
begin
   if((property_value > 2147483647) or (property_value < -2147483647)) then
--      dbms_sys_error.raise_system_error(-24193, '-2147483647 to 2147483647');

      raise_application_error(-20193, 'property value out of range [-2147483647, 2147483647]: ' ||
                              property_value);
   end if;

   if(p_jms_text_message.header.properties is null) then
      p_jms_text_message.header.properties := sys.aq$_jms_userproparray(
         sys.aq$_jms_userproperty(property_name, 200, null, property_value, 23));
   else
      lookup_property_name(p_jms_text_message.header.properties, property_name);

      p_jms_text_message.header.properties.extend;

      p_jms_text_message.header.properties(p_jms_text_message.header.properties.count) :=
         sys.aq$_jms_userproperty(property_name, 200,  null, property_value, 23);
   end if;
end set_int_property;

procedure set_string_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                              property_name      in            varchar,
                              property_value     in            varchar)
is
   l_property_value varchar2(2000);
begin
   -- YOHUANG: JMS Property has 2000 characters limit while ERROR_MESSAGE and ERROR_STACK
   -- can be 4000 characters long. Bug 3628473
   l_property_value := substr(property_value, 1 , 2000);
   if(p_jms_text_message.header.properties is null) then
       p_jms_text_message.header.properties := sys.aq$_jms_userproparray(
         sys.aq$_jms_userproperty(property_name, 100, l_property_value, null, 27));
   else
      lookup_property_name(p_jms_text_message.header.properties, property_name);

      p_jms_text_message.header.properties.extend;

      p_jms_text_message.header.properties(p_jms_text_message.header.properties.count) :=
         sys.aq$_jms_userproperty(property_name, 100, l_property_value, null, 27);
   end if;
end set_string_property;

function get_boolean_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                              property_name      in            varchar)
   return boolean
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 20)) then
         if(p_jms_text_message.header.properties(i).num_value is not null) then
            if(p_jms_text_message.header.properties(i).num_value = 0) then
               return false;
            else
               return true;
            end if;
         else
            return null;
         end if;
      end if;
   end loop;

   return null;
end get_boolean_property;

function get_byte_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                           property_name      in            varchar)
   return int
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 21)) then
         return p_jms_text_message.header.properties(i).num_value;
      end if;
   end loop;

   return null;
end get_byte_property;

function get_short_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                            property_name      in            varchar)
   return int
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 22)) then
         return p_jms_text_message.header.properties(i).num_value;
      end if;
   end loop;

   return null;
end get_short_property;

function get_int_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                          property_name      in            varchar)
   return int
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 23)) then
         return p_jms_text_message.header.properties(i).num_value;
      end if;
   end loop;

   return null;
end get_int_property;

function get_long_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                           property_name      in            varchar)
   return number
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 24)) then
         return p_jms_text_message.header.properties(i).num_value;
      end if;
   end loop;

   return null;
end get_long_property;

function get_float_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                            property_name      in            varchar)
   return float
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 25)) then
         return p_jms_text_message.header.properties(i).num_value;
      end if;
   end loop;

   return null;
end get_float_property;

function get_double_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                             property_name      in            varchar)
   return double precision
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 26)) then
         return p_jms_text_message.header.properties(i).num_value;
      end if;
   end loop;

   return null;
end get_double_property;

function get_string_property(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                             property_name      in            varchar)
   return varchar
is
begin
   for i in p_jms_text_message.header.properties.first ..
            p_jms_text_message.header.properties.last loop
      if((p_jms_text_message.header.properties(i).name = property_name) and
         (p_jms_text_message.header.properties(i).java_type = 27)) then
         return p_jms_text_message.header.properties(i).str_value;
      end if;
   end loop;

   return null;
end get_string_property;

procedure set_text(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                   payload            in            clob)
is
   l_text varchar2(4000);
   l_length number;

   invalid_lob_locator exception;
   pragma exception_init(invalid_lob_locator, -22275);
begin
   if(payload is null) then
      p_jms_text_message.text_len := 0;

      p_jms_text_message.text_vc := null;
      p_jms_text_message.text_lob := null;
   else
      begin
         p_jms_text_message.text_len := dbms_lob.getLength(payload);

         if(p_jms_text_message.text_len = 0) then
            p_jms_text_message.text_vc := null;
            p_jms_text_message.text_lob := null;
         else
            --Bug 2632448
            l_length := lengthb(dbms_lob.substr(payload));

            if(l_length <= 4000) then
               --elsif(p_jms_text_message.text_len <= 4000) then
               dbms_lob.read(lob_loc => payload,
                             amount  => p_jms_text_message.text_len,
                             offset  => 1,
                             buffer  => l_text);

               p_jms_text_message.text_vc := l_text;

               -- ANKUNG
               -- Because of bug 2676012, we need to set both the varchar
               -- and the clob with the data
               -- p_jms_text_message.text_lob := null;
               p_jms_text_message.text_lob := payload;
            else
               p_jms_text_message.text_vc := null;
               p_jms_text_message.text_lob := payload;
            end if;
         end if;
      exception
         when invalid_lob_locator then
            -- when 'payload' is an empty_clob, dbms_lob.getLength(payload)
            -- raises an 'ORA-22275: invalid LOB locator specified' error

            p_jms_text_message.text_len := 0;

            p_jms_text_message.text_vc := null;
            p_jms_text_message.text_lob := null;
      end;
   end if;
end set_text;

procedure get_text(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                   payload            out    nocopy clob)
is
l_text_lob_length number;
begin

   begin
     if p_jms_text_message.text_lob is null then
       l_text_lob_length := 0;
     else
       l_text_lob_length := dbms_lob.getlength(p_jms_text_message.text_lob);
     end if;
   exception
     when others then
       l_text_lob_length := 0;
   end;

   -- ANKUNG
   -- Because of bug 2676012, we set both the varchar and the clob with the
   -- data
   --if(p_jms_text_message.text_vc is not null) then

   if(p_jms_text_message.text_vc is not null and
      l_text_lob_length = 0) then

      dbms_lob.createTemporary(lob_loc => payload,
                               cache   => true);

      dbms_lob.write(lob_loc => payload,
                     amount  => p_jms_text_message.text_len,
                     offset  => 1,
                     buffer  => p_jms_text_message.text_vc);
   else
      payload := p_jms_text_message.text_lob;
   end if;
end get_text;

--------------------------------------------------------------------------------
-- Returns true iff the parameter name is a user parameter.
--
-- p_parameter_name - the parameter name
--
-- return: true if the parameter name is a user parameter; false otherwise
--------------------------------------------------------------------------------
function is_user_parameter(p_parameter_name in varchar2) return boolean
is
begin
   if((instr(p_parameter_name, 'BES_') <> 1) or
      p_parameter_name in ('BES_DATABASE_ID', 'BES_SECURITY_GROUP_ID', PAYLOAD_OBJECT)) then
      -- the parameter name does not begin with 'BES_'
      -- (or it is an exception) so it is a user parameter

      return true;
   else
      -- the parameter name is not a user parameter

      return false;
   end if;
end is_user_parameter;

--------------------------------------------------------------------------------
-- Tranforms a business event into a JMS Text Message.
--
-- p_event - the business event to transform
-- p_jms_text_message - the JMS Text Message
--------------------------------------------------------------------------------
procedure serialize(p_event            in         wf_event_t,
                    p_jms_text_message out nocopy sys.aq$_jms_text_message)
is
   l_replyto varchar2(2000);
   l_priority int;
   i1 integer;
   i2 integer;
   l_agent_name varchar2(30);
   l_address varchar2(1024);
   l_protocol number;
   l_aq_agent sys.aq$_agent;
   l_wf_agent wf_agent_t;
   l_parameter_list wf_parameter_list_t;
   l_correlation_id varchar2(240);
begin
   p_jms_text_message := sys.aq$_jms_text_message(
      sys.aq$_jms_header(null, null, null, null, null, 0, null), 0, null, null);

   -- set the JMS properties

   set_type(p_jms_text_message, p_event.getValueForParameter(JMS_TYPE));
   set_userid(p_jms_text_message, p_event.getValueForParameter(JMS_USERID));
   set_appid(p_jms_text_message, p_event.getValueForParameter(JMS_APPID));
   set_groupid(p_jms_text_message, p_event.getValueForParameter(JMS_GROUPID));
   set_groupseq(p_jms_text_message, p_event.getValueForParameter(JMS_GROUPSEQ));

   set_string_property(p_jms_text_message, EVENT_NAME, p_event.getEventName());
   set_string_property(p_jms_text_message, EVENT_KEY, p_event.getEventKey());

   -- parse the replyto attribute which must be in the form
   -- "name:address:protocol"

   l_replyto := p_event.getValueforParameter(JMS_REPLYTO);

   if(l_replyto is not null) then
      i1 := instr(l_replyto, ':');
      i2 := instr(l_replyto, ':', 1, 2);

      l_agent_name := substr(l_replyto, 1, i1 - 1);
      l_address := substr(l_replyto, i1 + 1, i2 - i1 - 1);
      l_protocol := substr(l_replyto, i2 + 1);

      l_aq_agent := sys.aq$_agent(l_agent_name, l_address, l_protocol);

      set_replyto(p_jms_text_message, l_aq_agent);
   end if;

   -- set the priority

   if(p_event.getPriority() is not null) then
      -- get the priority from the event

      l_priority := p_event.getPriority();
   elsif(p_event.getValueForParameter(PRIORITY) is not null) then
      -- get the priority from the event parameters

      l_priority := p_event.getValueForParameter(PRIORITY);
   else
      -- use the default priority

      l_priority := DEFAULT_PRIORITY;
   end if;

   set_int_property(p_jms_text_message, PRIORITY, l_priority);

   -- set the send date

   if(p_event.getSendDate() is not null) then
      set_string_property(p_jms_text_message, SEND_DATE, to_char(p_event.getSendDate(), DATE_MASK));
   end if;

   -- set the receive date

   if(p_event.getReceiveDate() is not null) then
      set_string_property(p_jms_text_message, RECEIVE_DATE, to_char(p_event.getReceiveDate(), DATE_MASK));
   end if;

   -- set the correlation id

   if(p_event.getCorrelationId() is not null) then
      -- get the correlation id from the event

      l_correlation_id := p_event.getCorrelationId();
   elsif(p_event.getValueForParameter(CORRELATION_ID) is not null) then
      -- get the correlation id from the event parameters

      l_correlation_id := p_event.getValueForParameter(CORRELATION_ID);
   else
      l_correlation_id := null;
   end if;

   if(l_correlation_id is not null) then
      set_string_property(p_jms_text_message, CORRELATION_ID, l_correlation_id);
   end if;

   -- set the from agent

   l_wf_agent := p_event.getFromAgent();

   if(l_wf_agent is not null) then
      set_string_property(p_jms_text_message, FROM_AGENT, l_wf_agent.getName() || '@'
         || l_wf_agent.getSystem());
   end if;

   -- set the to agent

   l_wf_agent := p_event.getToAgent();

   if(l_wf_agent is not null) then
      set_string_property(p_jms_text_message, TO_AGENT, l_wf_agent.getName() || '@'
         || l_wf_agent.getSystem());
   end if;

   -- set the error subscription

   if(p_event.getErrorSubscription() is not null) then
      set_string_property(p_jms_text_message, ERROR_SUBSCRIPTION, p_event.getErrorSubscription());
   end if;

   -- set the error message

   if(p_event.getErrorMessage() is not null) then
      set_string_property(p_jms_text_message, ERROR_MESSAGE, p_event.getErrorMessage());
   end if;

   -- set the error stack

   if(p_event.getErrorStack() is not null) then
      set_string_property(p_jms_text_message, ERROR_STACK, p_event.getErrorStack());
   end if;

   -- set the wf_event_t user-defined properties

   l_parameter_list := p_event.getParameterList();

   if(l_parameter_list is not null and
      l_parameter_list.first is not null) then
      for i in l_parameter_list.first .. l_parameter_list.last loop
         if(is_user_parameter(l_parameter_list(i).getName())) then
            set_string_property(p_jms_text_message, l_parameter_list(i).getName(),
               l_parameter_list(i).getValue());
         end if;
      end loop;
   end if;

   -- set the text payload

   set_text(p_jms_text_message, p_event.getEventData());

exception when others then
   wf_core.context('WF_EVENT_OJMSTEXT_QH', 'serialize',
      'SQL error is ' || substr(sqlerrm, 1, 200));
   raise;
end serialize;

--------------------------------------------------------------------------------
-- Tranforms a JMS Text Message into a business event.
--
-- p_jms_text_message - the JMS Text Message
-- p_event - the business event
--------------------------------------------------------------------------------
procedure deserialize(p_jms_text_message in out nocopy sys.aq$_jms_text_message,
                      p_event            out    nocopy wf_event_t)
is
   i1 integer;

   l_jms_agent   varchar2(2000);
   l_agent_name  varchar2(30);
   l_system_name varchar2(30);
   l_from_agent  wf_agent_t;
   l_to_agent    wf_agent_t;

   l_jms_user_properties sys.aq$_jms_userproparray;
   l_jms_property_name   varchar2(100);
   l_jms_property_value  varchar2(2000);
   l_boolean_value       boolean;

   l_clob clob;
begin
   p_event := wf_event_t(0, null, null, null, null, null, null, null, null,
      null, null, null, null);

   if(p_jms_text_message.header.properties.count > 0) then
      -- set the wf_event properties

      p_event.setEventName(get_string_property(p_jms_text_message, EVENT_NAME));
      p_event.setEventKey(get_string_property(p_jms_text_message, EVENT_KEY));
      p_event.setPriority(get_int_property(p_jms_text_message, PRIORITY));
      p_event.setSendDate(to_date(get_string_property(p_jms_text_message, SEND_DATE), DATE_MASK));
      p_event.setReceiveDate(to_date(get_string_property(p_jms_text_message, RECEIVE_DATE), DATE_MASK));
      p_event.setCorrelationId(get_string_property(p_jms_text_message, CORRELATION_ID));

      -- parse the from agent which must be in the form "name@system"

      l_jms_agent := get_string_property(p_jms_text_message, FROM_AGENT);

      if(l_jms_agent is not null) then
         i1 := instr(l_jms_agent, '@');

         l_agent_name := substr(l_jms_agent, 1, i1 - 1);
         l_system_name := substr(l_jms_agent, i1 + 1);

         l_from_agent := wf_agent_t(l_agent_name, l_system_name);

         p_event.setFromAgent(l_from_agent);
      end if;

      -- parse the to agent which must be in the form "name@system"

      l_jms_agent := get_string_property(p_jms_text_message, TO_AGENT);

      if(l_jms_agent is not null) then
         i1 := instr(l_jms_agent, '@');

         l_agent_name := substr(l_jms_agent, 1, i1 - 1);
         l_system_name := substr(l_jms_agent, i1 + 1);

         l_to_agent := wf_agent_t(l_agent_name, l_system_name);

         p_event.setToAgent(l_to_agent);
      end if;

      p_event.setErrorSubscription(get_string_property(p_jms_text_message, ERROR_SUBSCRIPTION));
      p_event.setErrorMessage(get_string_property(p_jms_text_message, ERROR_MESSAGE));
      p_event.setErrorStack(get_string_property(p_jms_text_message, ERROR_STACK));

      -- set the wf_event user-defined properties

      l_jms_user_properties := p_jms_text_message.header.properties;

      if(l_jms_user_properties.count > 0) then
         for i in l_jms_user_properties.first .. l_jms_user_properties.last loop
            l_jms_property_name := l_jms_user_properties(i).name;

            if(is_user_parameter(l_jms_property_name)) then
               -- since we don't know the property type, try retrieving the value
               -- as each possible type until we find it (get a non-null value)

               -- get the property as a string

               l_jms_property_value :=
                  get_string_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

               -- get the property as an int

               l_jms_property_value :=
                  get_int_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

               -- get the property as a boolean

               l_boolean_value :=
                  get_boolean_property(p_jms_text_message, l_jms_property_name);

               if(l_boolean_value is not null) then
                  if(l_boolean_value) then
                     l_jms_property_value := 'true';
                  else
                     l_jms_property_value := 'false';
                  end if;

                  goto found;
               end if;

               -- get the property as a byte

               l_jms_property_value :=
                  get_byte_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

               -- get the property as a short

               l_jms_property_value :=
                  get_short_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

               -- get the property as a long

               l_jms_property_value :=
                  get_long_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

               -- get the property as a float

               l_jms_property_value :=
                  get_float_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

               -- get the property as a double

               l_jms_property_value :=
                  get_double_property(p_jms_text_message, l_jms_property_name);

               if(l_jms_property_value is not null) then
                  goto found;
               end if;

<<found>>      null;

               -- At this point, if l_jms_property_value is null, that means that
               -- the property value really is null.  In that case, do not add the
               -- property to the parameter list.

               if(l_jms_property_value is not null) then
                  p_event.addParameterToList(l_jms_property_name, l_jms_property_value);
               end if;
            end if;
         end loop;
      end if;
   end if;

   -- set the event data

   get_text(p_jms_text_message, l_clob);

   p_event.setEventData(l_clob);
end deserialize;

--------------------------------------------------------------------------------
-- Enqueues a business event into a JMS queue.
--
-- p_event - the business event to enqueue
-- p_out_agent_override - the out agent override
--------------------------------------------------------------------------------
procedure enqueue(p_event              in wf_event_t,
                  p_out_agent_override in wf_agent_t)
is
   l_jms_text_message sys.aq$_jms_text_message;

   l_out_agent_name  varchar2(30);
   l_out_system_name varchar2(30);
   l_out_queue_name  varchar2(80);
   l_q_correlation_id   varchar2(240);

   l_to_agent_name      varchar2(30);
   l_to_system_name     varchar2(30);
   l_to_queue_name      varchar2(80);
   l_to_address         varchar2(1024);
   l_to_protocol        varchar2(30);
   l_to_protocol_number number;

   l_delay              number;
   l_enqueue_options    dbms_aq.enqueue_options_t;
   l_message_properties dbms_aq.message_properties_t;
   l_msgid              raw(16);

  i    number :=1;
  l_type   varchar2(8);
begin
   serialize(p_event, l_jms_text_message);

   -- determine the out queue

   if(p_out_agent_override is not null) then
      l_out_agent_name := p_out_agent_override.getName();
      l_out_system_name := p_out_agent_override.getSystem();
   else
      l_out_agent_name := p_event.getFromAgent().getName();
      l_out_system_name := p_event.getFromAgent().getSystem();
   end if;

   -- get the out queue name

   select wfa.queue_name into l_out_queue_name
   from wf_agents wfa,
        wf_systems wfs
   where wfa.name = l_out_agent_name
   and wfs.name = l_out_system_name
   and wfs.guid = wfa.system_guid;

   -- if there is a to queue, we need to set the recipient list address

   if((p_event.getToAgent() is not null) and
      (l_out_agent_name <> 'WF_DEFERRED')) then
        WF_EVENT.Set_Recipient_List(p_event,
                                    l_out_agent_name ,
                                    l_out_system_name,
                                    l_message_properties);
   end if;

   -- set the priority

   l_message_properties.priority := get_int_property(l_jms_text_message,
      PRIORITY);

   -- set the delay if required; also used for deferred agent

   if(p_event.getSendDate() > sysdate) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT_OJMSTEXT_QH.enqueue.delay',
                          'Delay Detected');
      end if;

      l_delay := (p_event.getSendDate() - sysdate)*24*60*60;

      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT_OJMSTEXT_QH.enqueue.delay_time',
                          'delay = ' || to_char(l_delay));
      end if;

      if(l_delay > 1) then
         -- message_properties.delay is BINARY_INTEGER so check if delay is
         -- too big, and set the max delay to be 2**31 - 1

         if(l_delay >= power(2, 31)) then
            l_message_properties.delay := power(2, 31) - 1;
         else
            l_message_properties.delay := l_delay;
         end if;
      end if;

    else -- senddate may not be set, or it could be less than sysdate

     -- for Web Services, it is possible for the SOAP client to directly
     -- set the #MSG_DELAY parameter in the p_event. In so doing, the SOAP
     -- client indicates how far later shall a message be dequeued next time.
     -- the SOAP client does not use the senddate to achieve that because, the
     -- SOAP java midtier time may be inconsistant to the sysdate in DB.
     l_delay := p_event.getValueForParameter ('#MSG_DELAY');

     if (l_delay is not NULL) then

        if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT_OJMSTEXT_QH.enqueue.delay',
                            'Delay Detected');
           wf_log_pkg.string(wf_log_pkg.level_statement,
                            'wf.plsql.WF_EVENT_OJMSTEXT_QH.enqueue.delay_time',
                            'delay = ' || to_char(l_delay));
        end if;


        if(l_delay > 1) then

           -- message_properties.delay is BINARY_INTEGER so check if delay is
           -- too big, and set the max delay to be 2**31 - 1

          if(l_delay >= power(2, 31)) then
             l_message_properties.delay := power(2, 31) - 1;
          else
             l_message_properties.delay := l_delay;
          end if;
        end if;

     end if; -- l_delay is not NULL

   end if;  -- p_event.getSendDate


   -- if we are enqueuing for an internal agent, must set the account name
   -- into the correlation id
   if (l_out_agent_name like 'WF_%'
       or l_to_agent_name like 'WF_%') then
    if wf_event.account_name is null then
      wf_event.SetAccountName;
    end if;
    l_message_properties.correlation := wf_event.account_name;
   end if;

   IF ((l_out_agent_name = 'WF_JAVA_DEFERRED') OR
       (l_to_agent_name = 'WF_JAVA_DEFERRED') OR
       (l_out_agent_name = 'WF_JAVA_ERROR') OR
       (l_to_agent_name = 'WF_JAVA_ERROR')) THEN

      l_q_correlation_id := p_event.event_name;
   else
    l_q_correlation_id := p_event.getValueForParameter('Q_CORRELATION_ID');
   end if;

   IF (l_q_correlation_id IS NOT NULL) THEN
     -- If account name is set, append account name in front of correlation id.
     if (l_message_properties.correlation is not null) then
        l_message_properties.correlation := l_message_properties.correlation ||
                                            ':' || l_q_correlation_id;
     else
        l_message_properties.correlation := l_q_correlation_id;
     end if;
   END IF;

   if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_statement,
                       'wf.plsql.WF_EVENT_OJMSTEXT_QH.enqueue.dbms_aq',
                       'Calling dbms_aq.enqueue');
   end if;

   dbms_aq.enqueue(queue_name         => l_out_queue_name,
                   enqueue_options    => l_enqueue_options,
                   message_properties => l_message_properties,
                   payload            => l_jms_text_message,
                   msgid              => l_msgid);

   -- Storing the enqueue msgid, similar to that been done WF_EVENT_QH
    WF_EVENT.g_msgid := l_msgid;

   if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,
                       'wf.plsql.WF_EVENT_OJMSTEXT_QH.enqueue.End',
                       'Finished calling dbms_aq.enqueue');
   end if;

exception
   when others then
      wf_core.context('WF_EVENT_OJMSTEXT_QH', 'enqueue', l_out_queue_name,
         'SQL error is ' || substr(sqlerrm, 1, 200));
      raise;
end enqueue;

--------------------------------------------------------------------------------
-- Dequeues a business event from a JMS queue.
--
-- p_agent_guid - the agent GUID
-- p_event - the business event
-- p_wait - the number of seconds to wait to dequeue the event
--------------------------------------------------------------------------------

procedure dequeue(p_agent_guid in         raw,
                  p_event      out nocopy wf_event_t,
                  p_wait       in         binary_integer)
is
   l_queue_name          varchar2(80);
   l_agent_name          varchar2(30);
   l_dequeue_options     dbms_aq.dequeue_options_t;
   l_message_properties  dbms_aq.message_properties_t;
   l_jms_text_message    sys.aq$_jms_text_message;
   l_msgid               raw(16);

   no_messages           exception;
   pragma exception_init(no_messages, -25228);
   --Define the snapshot too old error
   snap_too_old exception;
   pragma exception_init(snap_too_old, -1555);
begin

   -- get the agent name
   select upper(queue_name),
          upper(name)
   into l_queue_name,
        l_agent_name
   from wf_agents
   where guid = p_agent_guid;

   if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,
                       'wf.plsql.WF_EVENT_OJMSTEXT_QH.dequeue.Begin',
                       'Dequeuing '||l_queue_name||' on '||l_agent_name);
   end if;

   -- Set correlation if the g_correlation is not null
   if (WF_EVENT.g_correlation is not null and WF_EVENT.g_correlation <> '%') then

     -- If seeded agent, set the account name as the prefix of correlation.
     if (l_agent_name like 'WF_%') then

       if(wf_event.account_name is null) then
         wf_event.setAccountName();
       end if;

        l_dequeue_options.correlation := wf_event.account_name || ':' ||WF_EVENT.g_correlation;

     else
       l_dequeue_options.correlation :=  WF_EVENT.g_correlation;
     end if;

     if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT_OJMSTEXT_QH.dequeue.corr',
                          'Setting correlation: ' || l_dequeue_options.correlation);
     end if;

   END IF;

   -- set the dequeue options
   l_dequeue_options.consumer_name := l_agent_name;
   l_dequeue_options.wait := p_wait;
   l_dequeue_options.navigation := wf_event.getQueueNavigation;

   begin
      dbms_aq.dequeue(queue_name         => l_queue_name,
                      dequeue_options    => l_dequeue_options,
                      message_properties => l_message_properties, -- out
                      payload            => l_jms_text_message,   -- out
                      msgid              => l_msgid);             -- out

   exception
      when no_messages then
         if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
            wf_log_pkg.string(wf_log_pkg.level_event,
                             'wf.plsql.WF_EVENT_OJMSTEXT_QH.dequeue.queue_empty',
                             'No more messages in dequeue.');
         end if;

         -- reset navigation
         wf_event.resetNavigationParams;
         p_event := null;

         return;
    --Capture the snapshot too old error
    when snap_too_old then
        -- reset navigation
        wf_event.resetNavigationParams;
        l_dequeue_options.navigation := wf_event.getQueueNavigation;
        dbms_aq.dequeue(queue_name         => l_queue_name,
                        dequeue_options    => l_dequeue_options,
                        message_properties => l_message_properties, -- out
                        payload            => l_jms_text_message,   -- out
                        msgid              => l_msgid);             -- out

     when others then
        wf_event.resetNavigationParams;
        raise;
   end;

   deserialize(l_jms_text_message, p_event);

   -- Set the number of dequeue attempts made for this message
   p_event.addParameterToList('#MSG_DQ_ATTEMPTS',
                            to_char(l_message_properties.attempts));
   -- set the receive date

   p_event.setReceiveDate(sysdate);

   -- set the msgid to the event
   p_event.addparametertolist('#MSG_ID', l_msgid);

   if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,
                       'wf.plsql.WF_EVENT_OJMSTEXT_QH.dequeue.End',
                       'Finished');
   end if;

exception
   when others then
      wf_core.context('WF_EVENT_OJMSTEXT_QH', 'Dequeue', l_queue_name,
         'SQL error is ' || substr(sqlerrm, 1, 200));
      raise;
end dequeue;

end wf_event_ojmstext_qh;

/
