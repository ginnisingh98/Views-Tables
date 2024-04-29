--------------------------------------------------------
--  DDL for Package Body FND_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EVENT" as
/* $Header: AFAMEVTB.pls 120.2 2005/08/19 18:23:08 tkamiya ship $ */


   -- Used to set the context for the event
   g_application_id    number;
   g_source_appl_id    number;
   g_event_id          number;
   g_source_id         number;
   g_dest_type         varchar2(1);
   g_message_name      varchar2(30);
   g_severity          varchar2(30);
   g_msgset            boolean;
   g_message_appl      varchar2(50);
   g_source_type       varchar2(1);
   g_module            varchar2(255);
   g_user_id           number;
   g_resp_appl_id      number;
   g_responsibility_id number;
   g_security_group_id      number;
   g_session_id        number;
   g_node              varchar2(30);
   g_db_instance       varchar2(16);
   g_audsid            number;

   g_total_events number := null;
   g_remaining_events number := NULL;
   previous_source_id number := NULL; -- used to store previous calls source_id
   previous_source_type varchar2(1) := NULL; --  to store prev calls scr type

     TYPE token_record_type is record
             (token    varchar2(30),
              type     varchar2(1),
              value    varchar2(2000));

     TYPE token_tab_type is table of token_record_type
             index by binary_integer;

     TYPE events_record_type is record
	     (event_id   number,
	      event      varchar2(2000));

     TYPE events_tab_type is table of events_record_type
              index by binary_integer;

   g_token_count            number := 0;
   g_tokens token_tab_type;
   g_events events_tab_type;


--
-- Private Functions
--
  --
  -- Name
  --   reset_vars
  --
  -- Purpose
  --   Initializes all private variables.
  --
  procedure reset_vars is
    empty_token token_tab_type;
  begin
   g_event_id       := 0;
   g_source_appl_id := null;
   g_source_type    := null;
   g_source_id      := null;
   g_dest_type      := null;
   g_message_appl   := null;
   g_message_name   := null;
   g_severity       := null;
   g_module            := null;
   g_user_id           := 0;
   g_resp_appl_id      := 0;
   g_responsibility_id := 0;
   g_security_group_id      := 0;
   g_session_id        := 0;
   g_node              := null;
   g_db_instance       := null;
   g_audsid            := 0;

   g_msgset         := FALSE;
   g_token_count    := 0;
   g_tokens         := empty_token;
  end;

-- Name : initialize
-- Description:
--       initialize sets the context for the event.
--       One has to call initialize before calling fnd_event.post.
--       Returns event_id if successfull otherwise 0.
-- Arguments:
--    source_application_id -
--    source_type - 'M'(manager)/'R'(Request)
--    source_id   - concurrent_process_id/concurrent_request_id
--    dest_type   - destination type
--    message_appl_short_name
--		  - application short name of the message
--    name        - message name
--    severity    - ERROR/WARNING/FATAL
--    module      - source module name
--

FUNCTION initialize(source_application_id IN NUMBER default 0,
                   source_type IN VARCHAR2,
                   source_id   IN NUMBER,
                   dest_type   IN VARCHAR2 default '0',
		   message_appl_short_name IN VARCHAR2,
                   name        IN VARCHAR2,
                   severity    IN VARCHAR2  default 'WARNING',
		   module      IN VARCHAR2 default Null) return number is
   empty_token token_tab_type;

   dual_no_rows exception;
   dual_too_many_rows exception;
BEGIN

   reset_vars;

   g_source_id      := source_id;
   g_source_appl_id := source_application_id;
   g_source_type    := source_type;
   g_module         := module;
   g_dest_type      := dest_type;
   g_message_appl   := message_appl_short_name;
   g_message_name   := name;
   g_severity       := severity;
   g_msgset         := TRUE;
   g_token_count    := 0;
   g_tokens         := empty_token;

   -- get next event_id from sequence
   begin
       select fnd_events_s.nextval
         into g_event_id
         from sys.dual;

   exception
       when no_data_found then
           raise dual_no_rows;
       when too_many_rows then
           raise dual_too_many_rows;
       when others then
           raise;
   end;

   return g_event_id;
   exception
      when dual_no_rows then
         fnd_message.set_name ('FND', 'No Rows in Dual');
         return(0);
      when dual_too_many_rows then
         fnd_message.set_name ('FND', 'Too many rows in Dual');
         return(0);
      when others then
         fnd_message.set_name ('FND', 'SQL-Generic error');
         fnd_message.set_token ('ERRNO', sqlcode, FALSE);
         fnd_message.set_token ('REASON', sqlerrm, FALSE);
         fnd_message.set_token ('ROUTINE', 'FND_EVENT.initialize:others',
					FALSE);

         return(0);
END;

-- Name : set_token
-- Description:
--     It sets the token name and token value.
--     Call this procedure for each token you have for a event.
--     call initialize before calling set_token
-- Arguments:
--     event_id - event_id value for which you are setting the token.
--     token - token name
--     value - token value
--   type - 'C' = Constant.   Value is used directly in the token
--                            substitution.
--          'S' = Select.     Value is a SQL statement which returns a single
--                            varchar2 value.  (e.g. A translated concurrent
--                            manager name.)  This statement is run when the
--                            even is retrieved, and the result is used in
--                            the token substitution.
--          'T' = Translate.  Value is a message name.  This message must
--                            belong to the same application as the
--                            message specified in the INITIALIZE function.
--                            The message text will be used in the token
--                            substitution.


PROCEDURE set_token(event_id IN number,
		    token    IN VARCHAR2,
                    value    IN VARCHAR2 default NULL,
                    type     IN VARCHAR2 default 'C') is
BEGIN
   -- if token is not null then keep it in table.
   -- convert translate parameter to proper value to store in db.

   if ( token is not null ) then
      g_token_count := g_token_count + 1;
      g_tokens(g_token_count).token := set_token.token;

      if ( set_token.type in ('C','T','S')) then
         g_tokens(g_token_count).type := set_token.type;
      else
         g_tokens(g_token_count).type := 'C';
      end if;

      g_tokens(g_token_count).value := set_token.value;
   end if;

END;

-- Name : post
-- Description:
--     It inserts the cp_event into fnd_events table, fnd_event_tokens
--     Call this function after calling initialize and optionally set_token.
--     If successfull it returns TRUE else returns FALSE.
-- Arguments: event_id - event_id for which you want to post events.

FUNCTION post (event_id IN number )
            return boolean is
    PRAGMA AUTONOMOUS_TRANSACTION;

    p_token_name  varchar2(30);
    p_token_value  varchar2(2000);
    p_token_translate  varchar2(1);
    i number;

    has_tokens varchar2(1);

    message_not_set    exception;
    dual_no_rows       exception;
    dual_too_many_rows exception;
    app_not_found      exception;
    source_id_null     exception;
    insert_error       exception;

BEGIN
   -- if message is set and message is not null then process
   if ( (g_message_name is null) and (not g_msgset) ) then
     raise message_not_set;
   end if;

   if ( g_token_count = 0 ) then
     has_tokens := 'N';
   else
     has_tokens := 'Y';
   end if;


    -- check source_id value
    if ( g_source_id is null ) then
          raise source_id_null;
    end if;

-- get global values

	g_user_id := FND_GLOBAL.user_id;
	g_responsibility_id := FND_GLOBAL.resp_id;
	g_resp_appl_id := FND_GLOBAL.resp_appl_id;
	g_security_group_id := FND_GLOBAL.security_group_id;
	g_db_instance  := FND_CONC_GLOBAL.ops_inst_num;

         begin
           g_session_id := icx_sec.getsessioncookie();
         exception
           when others then
             g_session_id := -1;
         end;

       select USERENV('SESSIONID')
         into g_audsid
         from sys.dual;

       select MACHINE
	 into g_node
	from v$session
	 where audsid = g_audsid;

	if (g_module is null) then
		select module
			into g_module
		from v$session
			where audsid = g_audsid;
	end if;

-- end global gets

    -- validate source_id value.
    -- If source_id is 0 or -1 then use session_id
    if ( g_source_id <= 0 ) then
	g_source_id := g_audsid;
       	g_source_type := 'O';  -- use source_type as Others
    end if;


    -- insert into fnd_events table
    begin
          insert into fnd_events
 	     (event_id, source_application_id, source_id,
              source_type, dest_type, message_appl_short_name,
	      message_name, module, user_id, resp_appl_id,
	      responsibility_id, security_group_id, session_id, node,
	      db_instance, audsid, time,
              severity, processed, tokens)
          values
	     (g_event_id, g_source_appl_id, g_source_id,
              g_source_type, g_dest_type, g_message_appl,
              g_message_name, g_module, g_user_id, g_resp_appl_id,
	      g_responsibility_id, g_security_group_id, g_session_id,
	      g_node, g_db_instance, g_audsid, sysdate,
              g_severity, 'N', has_tokens);

          if ( sql%rowcount = 0 ) then
             raise insert_error;
          end if;
    end;

    -- insert into fnd_event_tokens table
    begin
       for i in 1..g_token_count loop
              p_token_name := g_tokens(i).token;
              p_token_value := g_tokens(i).value;
              p_token_translate := g_tokens(i).type;

              insert into fnd_event_tokens
                     (event_id, token,
                      type, value)
              values
                     ( post.event_id, p_token_name,
                       p_token_translate, p_token_value);
              if (sql%rowcount = 0 ) then
                 raise insert_error;
              end if;
       end loop;
    end;

    reset_vars;

    commit;

    return TRUE;

   exception
      when message_not_set then
         rollback;
         return FALSE;
      when source_id_null then
         rollback;
         return FALSE;
      when insert_error then
         fnd_message.set_name ('FND', 'SQL-Generic error');
         fnd_message.set_token ('ERRNO', sqlcode, FALSE);
         fnd_message.set_token ('REASON', sqlerrm, FALSE);
         fnd_message.set_token (
                        'ROUTINE', 'FND_EVENT.post: insert_error', FALSE);
         rollback;
         return FALSE;
      when others then
         fnd_message.set_name ('FND', 'SQL-Generic error');
         fnd_message.set_token ('ERRNO', sqlcode, FALSE);
         fnd_message.set_token ('REASON', sqlerrm, FALSE);
         fnd_message.set_token ('ROUTINE', 'FND_EVENT.post: others', FALSE);

         rollback;
         return FALSE;
end;

-- Name : set_processed
-- Description:
--     It sets the processed flag to given value for a given event_id.
--
-- Arguments:
--    event_id   - number
--    flag       - varchar2

PROCEDURE set_processed ( event_id number,
			  flag     varchar2 default 'Y') is
    PRAGMA AUTONOMOUS_TRANSACTION;
    invalid_flag exception;
begin
   if ( upper(flag) not in ('Y','N') ) then
     raise invalid_flag;
   end if;

   update fnd_events
      set processed = upper(flag)
    where event_id = set_processed.event_id;

   commit;

   exception
      when invalid_flag then
         rollback;
      when others then
         rollback;
end;


-- Name : get
-- Description:
--     It gets the cp_event for a given source_id, source_type.
--     Call this function after calling set_name and optionally set_token and
--     log. It also gives the # of events still exists in the cp_events for
--     this souce_id and source_type.
--     Be causious while using this procedure in while or for loops.
--     It may lead to infinet loop.
--     Stop calling this procedure when you get remaining events = 0 for a
--     given source_id and source_type.
-- Arguments:
--     source_id    - event source id, IN parameter
--     source_type  - event source type, IN parameter
--     processed    - TRUE/FLASE to set the processed flag, IN parameter
--     message      - event message, OUT parameter
--     remaining    - how many more events exists, OUT parameter
-- If the call is successfull then it returns TRUE otherwise FALSE;

FUNCTION get ( source_id    IN number,
               source_type  IN varchar2,
               processed    IN boolean default FALSE,
               message      IN OUT NOCOPY varchar2,
               remaining    IN OUT NOCOPY number) return boolean is

  cursor c_conc_events(p_source_id number, p_source_type varchar2) is
     select /*+ index(FND_EVENTS) */ event_id, message_name, tokens
       from fnd_events
      where source_id = p_source_id
        and source_type = p_source_type
            order by event_id;

  cursor c_conc_tokens( p_event_id number) is
     select token, type, value
       from fnd_event_tokens
      where event_id = p_event_id;

     l_event_id     number;
     l_message_name varchar2(30);
     l_token        varchar2(30);
     l_translate    boolean;
     l_token_value  varchar2(2000);
     l_source_id    number;
     l_source_type  varchar2(1);
     i              number;
     empty_events   events_tab_type;

     routine     varchar2(50) default 'FND_EVENT.GET';
begin

    -- if the conc prog is running from OS then source_id will be either 0 or -1
    -- if source_id is 0 or -1 then use the session id
    if ( source_id <= 0 ) then
       select USERENV('SESSIONID')
         into l_source_id
         from sys.dual;
       l_source_type := 'O';  -- use source_type as Others
    else
       l_source_id := source_id;
       l_source_type := source_type;
    end if;

   -- test for null to find out query has got executed once or not.
   if (( g_total_events is null) and ((nvl(previous_source_id, 0) <> l_source_id)
           or (nvl(previous_source_type,'0') <> l_source_type))) then
      -- store these two values to find out caller needs for diff source
      previous_source_id := l_source_id;
      previous_source_type := l_source_type;

      -- empty events plsql table
      g_events := empty_events;

      for c_events in c_conc_events(l_source_id, l_source_type) loop
	 g_total_events := nvl(g_total_events,0) + 1;
         l_event_id := c_events.event_id;
	 l_message_name := c_events.message_name;
         -- set the message in message stack
         fnd_message.set_name('FND', l_message_name );

        if ( c_events.tokens = 'Y' ) then
         -- get all tokens for this event
         for c_tokens in c_conc_tokens( l_event_id ) loop
             l_token       := c_tokens.token;
             l_token_value := c_tokens.value;
             if ( c_tokens.type = 'C' ) then
                l_translate := FALSE;
             elsif ( c_tokens.type = 'T' ) then
                l_translate := TRUE;
	     elsif ( c_tokens.type = 'S' ) then
                declare
                   token_text varchar2(2000);
                begin
                  /* Set the routine name reported in exceptions,   *
                   * so that the API isn't blamed for bad token SQL.*/
                   routine := 'FND_EVENT.GET (Token SQL)';
                   execute immediate c_tokens.value
                        into l_token_value;
                   routine := 'FND_EVENT.GET';
                   l_translate := FALSE;
                end;
             end if;

             -- set this token in message stack
             fnd_message.set_token(l_token, l_token_value, l_translate);
         end loop;
        end if;   -- if there are any tokens

         -- get the translated message and store it in plsql tables
         g_events(g_total_events).event_id := l_event_id;
         g_events(g_total_events).event := fnd_message.get;
	 g_remaining_events := g_total_events;
      end loop;
   end if;

   -- get the events from plsql table and return to caller
   if ( g_remaining_events > 0 ) then
      i := g_total_events - g_remaining_events + 1;
      message := g_events(i).event;
      g_remaining_events := g_remaining_events - 1;
      remaining := g_remaining_events;

      -- set the processed flag if processed is passed
      if ( processed ) then
         set_processed(g_events(i).event_id, 'Y');
      end if;

      if ( g_remaining_events = 0 ) then
        g_total_events := NULL;
      end if;
      RETURN TRUE;
   else
      remaining := 0;
      message := NULL;
      g_total_events := NULL;

      RETURN TRUE;
   end if;

   exception
      when others then
         fnd_message.set_name ('FND', 'SQL-Generic error');
         fnd_message.set_token ('ERRNO', sqlcode, FALSE);
         fnd_message.set_token ('REASON', sqlerrm, FALSE);
         fnd_message.set_token ('ROUTINE', routine, FALSE);
         message := fnd_message.get;
         remaining := 0;
         g_total_events := NULL;
         rollback;
	 RETURN FALSE;
end;



  --
  -- Name
  --   OEM_GET
  --
  -- Purpose
  --   Retrieves the next unprocessed event with a destination type
  --   of 'O' from the fnd_events table.  The retrieved event is marked
  --   as processed.
  --
  -- Arguments
  --   event_text     - Text of the event. (out)
  --                    Buffer must be at least 2000 bytes.
  --   event_time     - Date/time of event posting.
  --   event_severity - 'WARNING' or 'ERROR'  --
  -- Returns
  --   0 - There are no unprocessed OEM events.
  --   1 - An event was successfully retrieved.
  --   2 - Error.  The event_text parameter will contain
  --       the error message.
  --
  -- Notes
  --   Error messages are returned in the event_text paramter.
  --
  function oem_get ( event_text out NOCOPY varchar2,
                     event_time     out NOCOPY date,
                     event_severity out NOCOPY varchar2 ) return number is
    pragma AUTONOMOUS_TRANSACTION;

    row_locked exception;
    pragma exception_init(row_locked, -54);

    cursor c1 is
         select event_id
           from fnd_events
          where processed = 'N';

    cursor c2 (instance_id number) is
         select token, type, value
           from fnd_event_tokens
          where event_id = instance_id;

    inst_id     number;
    msg_appl_sn varchar2(50);
    msg_name    varchar2(30) default null;
    sev         varchar2(30);
    t           date;
    token_flag  varchar2(1);
    routine     varchar2(50) default 'FND_EVENT.OEM_GET';
  begin
    /* Clear parameters */
    event_text := null;
    event_time := null;
    event_severity := null;

    for c1rec in c1 loop
      inst_id := c1rec.event_id;

      /* Make sure nobody else picked up the event. */
      begin
        select message_appl_short_name, message_name,
               time, severity, tokens
          into msg_appl_sn, msg_name, t, sev, token_flag
          from fnd_events
         where event_id = inst_id
           and processed = 'N'
         for update of processed nowait;
      exception
         when no_data_found then
           goto loop_end;
         when row_locked then
           goto loop_end;
      end;

      /* We've got the lock.  Mark the event has processed. */
      update fnd_events
         set processed = 'Y'
       where event_id = inst_id;

      commit;
      exit;

      <<loop_end>>
      null;
    end loop;

    if (msg_name is null) then
      /* Nothing was picked up from the queue */
      return 0;
    end if;

    fnd_message.set_name(msg_appl_sn, msg_name);

    if (token_flag = 'Y') then
      for c2rec in c2(inst_id) loop
        if (c2rec.type = 'C') then
          fnd_message.set_token(c2rec.token, c2rec.value, FALSE);
        elsif (c2rec.type = 'T') then
          fnd_message.set_token(c2rec.token, c2rec.value, TRUE);
        else /* Type S */
          declare
            token_text varchar2(2000);
          begin
            /* Set the routine name reported in exceptions,   *
             * so that the API isn't blamed for bad token SQL.*/
            routine := 'FND_EVENT.OEM_GET (Token SQL)';
            execute immediate c2rec.value
               into token_text;
            routine := 'FND_EVENT.OEM_GET';
            fnd_message.set_token(c2rec.token, token_text, FALSE);
         end;
        end if;
      end loop;
    end if;

    event_text := fnd_message.get;
    event_time := t;
    event_severity := sev;

    return 1;


  exception
    when others then
      fnd_message.set_name ('FND', 'SQL-Generic error');
      fnd_message.set_token ('ERRNO', sqlcode, FALSE);
      fnd_message.set_token ('REASON', sqlerrm, FALSE);
      fnd_message.set_token ('ROUTINE', routine, FALSE);
      event_text := fnd_message.get;
      rollback;
      return 2;
  end;


-- Name : oem_set_processed
-- Description:
--     It sets the processed flag to 'Y' for a given event_id.
--     Public wrapper function calling the private API
-- Arguments:
--    event_id   - number

FUNCTION oem_set_processed ( event_id number ) return number is
begin
   set_processed(event_id);
   return 1;

   exception
      when others then
         rollback;
	 RETURN 0;
end;

-- Name: oem_get_text
-- Description:
--     It gets the translated message text for a given event_id.
--
-- Arguments:
--    event_id   - number
FUNCTION oem_get_text ( event_id number ) return varchar2 is

    cursor c (instance_id number) is
         select token, type, value
           from fnd_event_tokens
          where event_id = instance_id;

    msg_appl_sn varchar2(50);
    msg_name    varchar2(30) default null;
    token_flag  varchar2(1);
    routine     varchar2(50) default 'FND_EVENT.OEM_GET_TEXT';
    event_text varchar2(2000);
begin

      select message_appl_short_name, message_name, tokens
          into msg_appl_sn, msg_name, token_flag
          from fnd_events
         where event_id = oem_get_text.event_id;

    if (msg_name is null) then
      return null;
    end if;

    fnd_message.set_name(msg_appl_sn, msg_name);

    if (token_flag = 'Y') then
      for c2rec in c(oem_get_text.event_id) loop
        if (c2rec.type = 'C') then
          fnd_message.set_token(c2rec.token, c2rec.value, FALSE);
        elsif (c2rec.type = 'T') then
          fnd_message.set_token(c2rec.token, c2rec.value, TRUE);
        else /* Type S */
          declare
            token_text varchar2(2000);
          begin
            /* Set the routine name reported in exceptions,   *
             * so that the API isn't blamed for bad token SQL.*/
            routine := 'FND_EVENT.OEM_GET_TEXT (Token SQL)';
            execute immediate c2rec.value
               into token_text;
            routine := 'FND_EVENT.OEM_GET_TEXT';
            fnd_message.set_token(c2rec.token, token_text, FALSE);
         end;
        end if;
      end loop;
    end if;

    event_text := fnd_message.get;

    return event_text;

  exception
    when others then
      fnd_message.set_name ('FND', 'SQL-Generic error');
      fnd_message.set_token ('ERRNO', sqlcode, FALSE);
      fnd_message.set_token ('REASON', sqlerrm, FALSE);
      fnd_message.set_token ('ROUTINE', routine, FALSE);
      event_text := fnd_message.get;
      rollback;
      return event_text;
end;

end FND_EVENT;

/
